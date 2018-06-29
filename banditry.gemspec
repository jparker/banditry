# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'banditry/version'

Gem::Specification.new do |spec|
  spec.name          = "banditry"
  spec.version       = Banditry::VERSION
  spec.authors       = ["John Parker"]
  spec.email         = ["jparker@urgetopunt.com"]

  spec.summary       = %q{Generic implementation of a bitmask.}
  spec.description   = %q{Banditry provides a generic wrapper class to manage a bitmask attribute. Formerly known as "banditmask".}
  spec.homepage      = "https://github.com/jparker/banditry"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency 'minitest', '~> 5.7'

  spec.add_development_dependency 'pry'
end
