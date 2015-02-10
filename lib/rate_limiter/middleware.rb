module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @limit     = options[:limit].to_s || "60"
      @remaining = @limit.to_i
    end

    def call(env)
      @remaining -= 1 if @remaining > 0
      if @remaining == 0
        status = '429 Too Many Requests'
        headers = { 'Content-Type' => 'text/plain' }
        response = ['Too Many Requests']
      else
        status, headers, response = @app.call(env)
      end
      headers["X-RateLimit-Remaining"] = @remaining.to_s
      headers["X-RateLimit-Limit"] = @limit
      [status, headers, response]
    end
  end
end

