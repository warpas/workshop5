module RateLimiter
  class Middleware
    def initialize(app, options = {}, &block)
      @app       = app
      @limit     = options[:limit].to_i || 60
      @resetIn   = options[:reset_in].to_i || 3600
      @clients   = {}
      @block     = block
    end

    def call(env)
      api_token = @block.call(env) if @block
      client_id = api_token || env["REMOTE_ADDR"]
      calculate_remaining(client_id)
      @clients[client_id] = { remaining: @remaining,
                                       reset:     @reset }
      if @remaining == 0
        prevent_access
      else
        @status, @headers, @response = @app.call(env)
      end
      add_headers
      [@status, @headers, @response]
    end

    private

    def calculate_remaining(address)
      if !@clients[address] || Time.now > @clients[address][:reset]
        @reset = Time.now + @resetIn
        @remaining = @limit
      elsif @clients[address]
        @remaining = @clients[address][:remaining]
      end
      @remaining -= 1 if @remaining > 0
    end

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

