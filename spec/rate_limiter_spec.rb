require 'spec_helper'
require 'timecop'

describe RateLimiter do
  let(:app) do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    Rack::Lint.new(RateLimiter::Middleware.new(app, { limit: "100" }))
  end

  before { get '/' }

  it 'should send the correct response' do
    expect(last_response.body).to eq('OK')
  end

  it 'should have the right header' do
    expect(last_response.header).to include("X-RateLimit-Limit")
  end

  it 'should accept the passed limit' do
    expect(last_response.header).to include("X-RateLimit-Limit" => "100")
  end

  it 'should decrease the limit with subsequent requests' do
    expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
    3.times { get '/' }
    expect(last_response.header).to include("X-RateLimit-Remaining" => "96")
  end

  it 'should prevent requests to the app once the limit is exceed' do
    100.times { get '/' }
    expect(last_response.status).to eq(429)
    expect(last_response.body).to_not eq('OK')
  end

  it 'should reset the limit after required time' do
    Timecop.travel(Time.now + 3601)
    get '/'
    expect(last_response.header).to include("X-RateLimit-Remaining" => "99")
  end
end
