Gem::Specification.new do |gem|
  gem.name = 'rack-canonical-host'
  gem.version = '0.0.3'
  gem.summary = %q{Rack middleware for defining a canonical host name.}
  gem.homepage = %q{http://github.com/tylerhunt/rack-canonical-host}
  gem.authors = ['Tyler Hunt']

  gem.files = Dir['LICENSE', 'README.rdoc', 'lib/**/*']

  gem.add_dependency 'rack', '>= 1.0.0'
end
