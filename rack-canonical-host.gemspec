require './lib/rack/canonical_host/version'

Gem::Specification.new do |gem|
  gem.name = 'rack-canonical-host'
  gem.version = Rack::CanonicalHost::VERSION
  gem.summary = 'Rack middleware for defining a canonical host name.'
  gem.homepage = 'http://github.com/tylerhunt/rack-canonical-host'
  gem.author = 'Tyler Hunt'

  gem.add_dependency 'addressable'
  gem.add_dependency 'rack', '~> 1.0'
  gem.add_development_dependency 'rspec', '~> 2.0'

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
