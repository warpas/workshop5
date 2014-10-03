require "rack/test"
require "minitest/autorun"

class HomepageTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new
  end

  def test_response
    get "/"

    assert_equal "http://example.org/redirected", last_request.url
    assert last_response.ok?
  end

end
