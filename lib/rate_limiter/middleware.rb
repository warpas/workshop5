module RateLimiter
  class Middleware
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      response = @app.call(env)
    end
  end
end

