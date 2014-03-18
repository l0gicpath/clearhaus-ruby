# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clearhaus/version'

Gem::Specification.new do |spec|
  spec.name          = "clearhaus"
  spec.version       = Clearhaus::VERSION
  spec.authors       = ["Hady"]
  spec.email         = ["hady.fathy@gmail.com"]
  spec.description   = %q{Some descriptive description}
  spec.summary       = %q{Some short summary}
  spec.homepage      = "http://docs.gateway.clearhaus.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec",   "~> 2.4"
  spec.add_development_dependency "webmock", "~> 1.17"
  spec.add_development_dependency "rake", "~> 0.9"
  spec.add_development_dependency "sinatra", "~> 1.4"


  spec.add_dependency "faraday", "~> 0.8"
  spec.add_dependency "json", "~> 1.7"
end
