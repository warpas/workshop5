require 'spec_helper'

describe RateLimiter do
  let(:app) { lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'OK'] } }
  subject { RateLimiter::Middleware.new(app) }

  before { get '/' }

  it 'should send the correct response' do
    expect(last_response.body).to eq('OK')
  end
end
