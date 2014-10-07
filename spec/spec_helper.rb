$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rate_limiter'
require 'rack/test'

RSpec.configure do |config|
 config.include Rack::Test::Methods
end
