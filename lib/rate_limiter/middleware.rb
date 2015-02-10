module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @limit     = options[:limit].to_s || "60"
      @remaining = @limit.to_i
    end

    def call(env)
      @remaining -= 1 if @remaining > 0
      status, headers, response = @app.call(env)
      headers["X-RateLimit-Limit"] = @limit
      headers["X-RateLimit-Remaining"] = @remaining.to_s
      if @remaining == 0
        status = '429 Too Many Requests'
        response = ['Too Many Requests']
      end
      [status, headers, response]
    end
  end
end

