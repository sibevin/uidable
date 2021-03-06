# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uidable/version'

Gem::Specification.new do |spec|
  spec.name          = "uidable"
  spec.version       = Uidable::VERSION
  spec.authors       = ["Sibevin Wang"]
  spec.email         = ["sibevin@gmail.com"]

  spec.summary       = %q{Create the uid attribute in your model or class.}
  spec.description   = <<-EOF
    Uidable is a module to add a uid(unique identifier) attribute in your model or class.
    With ActiveRecord, the presence and uniqueness validations are supported.
  EOF
  spec.homepage      = "https://github.com/sibevin/uidable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'
  spec.add_development_dependency "bundler", "~> 2.1.2"
  spec.add_development_dependency "rake", "~> 13.0"
end
