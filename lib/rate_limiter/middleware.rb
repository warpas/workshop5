module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @limit     = options[:limit] || 60
      @remaining = @limit
    end

    def call(env)
      @remaining -= 1
      status, headers, response = @app.call(env)
      headers["X-RateLimit-Limit"] = @limit
      headers["X-RateLimit-Remaining"] = @remaining
      [status, headers, response]
    end
  end
end

