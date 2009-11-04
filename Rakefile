require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = 'rack-canonical-host'
    gem.summary = %Q{Rack middleware for defining a canonical host name.}
    gem.description = %Q{Rack middleware for defining a canonical host name. It will redirect all requests to non-canonical hosts to the canonical host.}
    gem.email = 'tyler@tylerhunt.com'
    gem.homepage = 'http://github.com/tylerhunt/rack-canonical-host'
    gem.authors = ['Tyler Hunt']
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler'
end

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ''
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rack-canonical-host #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
