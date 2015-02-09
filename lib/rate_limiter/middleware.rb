module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      headers["X-RateLimit-Limit"] = "60"
      [status, headers, response]
    end
  end
end

