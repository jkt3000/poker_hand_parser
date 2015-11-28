# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'poker_hand_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "poker_hand_parser"
  spec.version       = PokerHandParser::VERSION
  spec.authors       = ["John Tajima"]
  spec.email         = ["manjiro@gmail.com"]
  spec.summary       = %q{PokerHandParser is a simple poker hand history parser}
  spec.description   = %q{PokerHandParser parses poker hand histories into a simple JSON format}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "activesupport"

  
end
