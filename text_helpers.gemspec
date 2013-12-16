# -*- encoding: utf-8 -*-
require File.expand_path('../lib/text_helpers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Horner"]
  gem.email         = ["andrew@tablexi.com"]

  gem.homepage      = "https://github.com/ahorner/text-helpers"
  gem.description   = %q{Easily fetch text and static content from your locales}
  gem.summary       = %q{
    TextHelpers is a gem which supplies some basic utilities for text
    localization in Rails projects.

    The library is intended to make it simple to keep your application's static
    and semi-static text content independent of the view structure.
  }

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.name          = "text_helpers"
  gem.require_paths = ["lib"]
  gem.version       = TextHelpers::VERSION
  gem.license       = "MIT"

  gem.add_dependency('activesupport')
  gem.add_dependency('i18n', '>=0.6.8')
  gem.add_dependency('github-markdown')
end
