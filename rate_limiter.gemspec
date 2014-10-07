# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rate_limiter/version'

Gem::Specification.new do |spec|
  spec.name          = "rate_limiter"
  spec.version       = RateLimiter::VERSION
  spec.authors       = ["Dawid Warpas"]
  spec.email         = ["dawid.warpas@gmail.com"]
  spec.summary       = %q{Simple rate limiter}
  spec.description   = %q{Simple rate limiter that behaves similarly to Github's API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
