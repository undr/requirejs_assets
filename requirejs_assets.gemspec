# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'requirejs_assets/version'

Gem::Specification.new do |gem|
  gem.name          = "requirejs_assets"
  gem.version       = RequirejsAssets::VERSION
  gem.authors       = ["undr"]
  gem.email         = ["undr@yandex.ru"]
  gem.description   = %q{Compilation of assets compatible with requirejs using sprockets}
  gem.summary       = %q{Compilation of assets compatible with requirejs using sprockets}
  gem.homepage      = ""

  gem.add_dependency 'railties', '>= 3.1.1', '< 3.3'
  gem.add_dependency 'rkelly'
  gem.add_dependency 'tilt'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rails', '~> 3.2.2'
  gem.add_development_dependency 'rspec-rails'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
