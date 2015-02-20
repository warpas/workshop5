require 'spec_helper'
require 'timecop'

describe RateLimiter do
  let(:app) do
    Rack::Builder.app do
      use Rack::Lint
      use RateLimiter::Middleware, limit: 100, reset_in: 7200
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    end
  end

  before { get '/' }

  it 'should send the correct response' do
    expect(last_response.body).to eq('OK')
  end

  describe 'Limit' do
    it 'should be present in header' do
      expect(last_response.header).to include("X-RateLimit-Limit")
    end

    it 'should reflect the value passed' do
      expect(last_response.header).to include("X-RateLimit-Limit" => "100")
    end
  end

  describe 'Remaining' do
    it 'should be decreased with subsequent requests' do
      expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
      3.times { get '/' }
      expect(last_response.header).to include("X-RateLimit-Remaining" => "96")
    end

    it 'should have seperate values for different clients' do
      expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
      4.times { get '/', {}, "REMOTE_ADDR" => "10.0.0.1" }
      expect(last_response.header).to include("X-RateLimit-Remaining" => "96")
      3.times { get '/', {}, "REMOTE_ADDR" => "10.0.42.1" }
      expect(last_response.header).to include("X-RateLimit-Remaining" => "97")
      4.times { get '/', {}, "REMOTE_ADDR" => "10.0.0.1" }
      expect(last_response.header).to include("X-RateLimit-Remaining" => "92")
    end

    describe 'Custom differentiation' do
      let(:app) do
        Rack::Builder.app do
          use Rack::Lint
          use RateLimiter::Middleware, limit: 100, reset_in: 7200 do
            |env| Rack::Request.new(env).params["api_token"]
          end
          run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
        end
      end

      it 'should have seperate values' do
        2.times { get '/', { 'api_token' => '47FUfXweoM9MlRev3LHTahi6' } }
        expect(last_response.header).to include("X-RateLimit-Remaining" => "98")
        5.times { get '/', { 'api_token' => 'bo2qc2tHNikfPmehfxTz2wBt' } }
        expect(last_response.header).to include("X-RateLimit-Remaining" => "95")
        4.times { get '/', { 'api_token' => 'XEsoCAq6bXE6PX6quIAt06QZ' } }
        expect(last_response.header).to include("X-RateLimit-Remaining" => "96")
      end

      it 'should not accept users without it' do
        2.times { get '/', {}, "REMOTE_ADDR" => "10.0.0.1" }
        expect(last_response.header).to_not include("X-RateLimit-Remaining")
      end
    end

    describe 'Reset' do
      it 'should occur after required amount of time passed' do
        Timecop.travel(Time.now + 7201)
        get '/'
        expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
      end

      describe 'Timer' do
        it 'should always update after the reset' do
          Timecop.travel(Time.now + 7201)
          3.times { get '/' }
          expect(last_response.header).to include("X-RateLimit-Remaining" => "97")
        end

        it 'should be seperate for different clients' do
          3.times { get '/' }
          Timecop.travel(Time.now + 3601)
          4.times { get '/', {}, "REMOTE_ADDR" => "10.0.0.1" }
          Timecop.travel(Time.now + 3601)
          get '/'
          expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
        end
      end
    end
  end

  it 'should prevent requests to the app once it reaches zero' do
    100.times { get '/' }
    expect(last_response.header).to include("X-RateLimit-Remaining" => "0")
    expect(last_response.status).to eq(429)
    expect(last_response.body).to_not eq('OK')
  end

  describe 'headers' do
    let(:app) do
      Rack::Builder.app do
        use Rack::Lint
        use RateLimiter::Middleware, limit: 100, reset_in: 7200 do
          nil
        end
        run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
      end
    end

    it 'should not be added if block passed returns nil' do
      2.times { get '/', {}, "REMOTE_ADDR" => '95.124.24.129' }
      expect(last_response.header).to_not include("X-RateLimit-Limit")
      expect(last_response.header).to_not include("X-RateLimit-Remaining")
      expect(last_response.body).to eq('OK')
    end
  end
end
