module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app   = app
      @limit = options[:limit] || 60
    end

    def call(env)
      status, headers, response = @app.call(env)
      headers["X-RateLimit-Limit"] = @limit
      [status, headers, response]
    end
  end
end

