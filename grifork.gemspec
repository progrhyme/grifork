# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grifork/version'

Gem::Specification.new do |spec|
  spec.name          = "grifork"
  spec.version       = Grifork::VERSION
  spec.authors       = ["key-amb"]
  spec.email         = ["yasutake.kiyoshi@gmail.com"]

  spec.summary       = %q{Fast Propagative Task Runner}
  spec.description   = %q{Fast propagative task runner for systems which consist of a lot of servers.}
  spec.homepage      = "https://github.com/key-amb/grifork"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["grifork"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0")

  spec.add_runtime_dependency "net-ssh", "~> 3.0"
  spec.add_runtime_dependency "parallel", "~> 1.9"
  spec.add_runtime_dependency "stdlogger", "~> 0.3.0"

  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
