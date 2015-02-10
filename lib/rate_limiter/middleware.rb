module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app       = app
      @limit     = options[:limit].to_i || 60
      @remaining = @limit
      @resetIn   = options[:reset_in].to_i || 3600
    end

    def call(env)
      @reset = Time.now + @resetIn if @remaining == @limit
      @remaining = @limit if Time.now > @reset
      @remaining -= 1 if @remaining > 0
      if @remaining == 0
        prevent_access
      else
        @status, @headers, @response = @app.call(env)
      end
      add_headers
      [@status, @headers, @response]
    end

    private

    def prevent_access
      @status = '429 Too Many Requests'
      @headers = { 'Content-Type' => 'text/plain' }
      @response = ['Too Many Requests']
    end

    def add_headers
      @headers["X-RateLimit-Remaining"] = @remaining.to_s
      @headers["X-RateLimit-Limit"] = @limit.to_s
      @headers["X-RateLimit-Reset"] = @reset.to_s
    end
  end
end

