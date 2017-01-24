# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rule1/version'

Gem::Specification.new do |spec|
  spec.name          = "rule1"
  spec.version       = Rule1::VERSION
  spec.authors       = ["Matt White"]
  spec.email         = ["mattw922@gmail.com"]
  spec.summary       = %q{Rule 1 opportunities finder}
  spec.description   = %q{Rule 1 opportunities finder. Uses Tradeking API.}
  spec.homepage      = "https://github.com/whitethunder/rule1"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 5.0.1"
  spec.add_runtime_dependency "dotenv", "~> 2.1.2"
  spec.add_runtime_dependency "hashie", "~> 3.4.6"
  spec.add_runtime_dependency "json", "~> 2.0.3"
  spec.add_runtime_dependency "oauth", "~> 0.5.1"

  spec.add_development_dependency "byebug", "~> 9.0.6"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.5"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "simplecov", "~> 0.12.0"
  spec.add_development_dependency "webmock", "~> 2.3.2"
  spec.add_development_dependency "vcr", "~> 3.0.3"
end
