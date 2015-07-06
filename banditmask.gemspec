# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'banditmask/version'

Gem::Specification.new do |spec|
  spec.name          = "banditmask"
  spec.version       = BanditMask::VERSION
  spec.authors       = ["John Parker"]
  spec.email         = ["jparker@urgetopunt.com"]

  spec.summary       = %q{Generic implementation of a bitmask.}
  spec.description   = %q{BanditMask provides a generic wrapper class to manage a bitmask attribute.}
  spec.homepage      = "https://github.com/jparker/banditmask"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'minitest', '~> 5.7'

  spec.add_development_dependency 'pry'
end
