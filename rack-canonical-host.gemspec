require './lib/rack/canonical_host/version'

Gem::Specification.new do |gem|
  gem.name = 'rack-canonical-host'
  gem.version = Rack::CanonicalHost::VERSION
  gem.licenses = ['MIT']
  gem.summary = 'Rack middleware for defining a canonical host name.'
  gem.homepage = 'https://github.com/tylerhunt/rack-canonical-host'
  gem.author = 'Tyler Hunt'

  gem.add_dependency 'addressable', '> 0', '< 3'
  gem.add_dependency 'rack', ['>= 1.0.0', '< 3']
  gem.add_development_dependency 'appraisal', '~> 2.2'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.0'

  gem.files = `git ls-files`.split($\)
  gem.require_paths = ['lib']
end
