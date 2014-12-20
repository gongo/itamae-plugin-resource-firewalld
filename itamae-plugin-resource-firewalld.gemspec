# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/plugin/resource/firewalld/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-plugin-resource-firewalld"
  spec.version       = Itamae::Plugin::Resource::Firewalld::VERSION
  spec.authors       = ["Wataru MIYAGUNI"]
  spec.email         = ["gonngo@gmail.com"]
  spec.summary       = %q{Itamae resource plugin to manage firewalld.}
  spec.description   = %q{Itamae resource plugin to manage firewalld.}
  spec.homepage      = "https://github.com/gongo/itamae-plugin-resource-firewalld"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'test-unit', '~> 3.0.1'
  spec.add_development_dependency 'mocha'
  spec.add_dependency 'itamae'
end
