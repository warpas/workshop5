require 'spec_helper'

describe RateLimiter do
  let(:app) do
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] }
    RateLimiter::Middleware.new(app, { limit: 100 })
  end

  before { get '/' }

  it 'should send the correct response' do
    expect(last_response.body).to eq('OK')
  end

  it 'should have the right header' do
    expect(last_response.header).to include("X-RateLimit-Limit")
  end

  it 'should accept the passed limit' do
    expect(last_response.header).to include("X-RateLimit-Limit" => 100)
  end
end
