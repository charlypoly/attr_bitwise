# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attr_bitwise/version'

Gem::Specification.new do |spec|
  spec.name          = "attr_bitwise"
  spec.version       = AttrBitwise::VERSION
  spec.authors       = ["Charly POLY"]
  spec.email         = ["cpoly55@gmail.com"]
  spec.summary       = %q{Bitwise attribute for ruby class and Rails model}
  spec.description   = %q{Bitwise attribute for ruby class and Rails model}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
