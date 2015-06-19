# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newsletterable/version'

Gem::Specification.new do |spec|
  spec.name          = "newsletterable"
  spec.version       = Newsletterable::VERSION
  spec.authors       = ["Stan Bondi"]
  spec.email         = ["stan@fixate.it"]
  spec.summary       = %q{ Keep mailing list subscriptions in sync with your models }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*', '[A-Z]*'] - ['Gemfile.lock']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel', ">= 3"
  spec.add_dependency 'activesupport', ">= 3"
  spec.add_dependency 'mailchimp-api', '>= 2'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "temping"
end
