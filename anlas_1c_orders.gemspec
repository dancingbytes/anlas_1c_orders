# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anlas_1c_orders/version'

Gem::Specification.new do |spec|

  spec.name          = "anlas_1c_orders"
  spec.version       = Anlas1cOrders::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Tyralion"]
  spec.email         = ["piliaiev@gmail.com"]

  spec.summary       = %q{Export orders from site to 1c.}
  spec.description   = %q{Export orders from site to 1c.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'railties'
  spec.add_dependency 'nokogiri', '~> 1.6.0'
  spec.add_dependency 'rubyzip',  '1.1.7'

end
