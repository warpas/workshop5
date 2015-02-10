module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @limit     = options[:limit].to_s || "60"
      @remaining = @limit.to_i
      @resetIn   = options[:reset_in].to_i || 3600
    end

    def call(env)
      @reset = Time.now + @resetIn if @remaining == @limit.to_i
      @remaining = @limit.to_i if Time.now > @reset
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
      headers["X-RateLimit-Reset"] = @reset.to_s
      [status, headers, response]
    end
  end
end

