Gem::Specification.new do |s|
  s.name = 'cuted'
  s.version = '1.0.0'
  s.date = '2012-04-03'
  s.summary = 'A simple single-machine batch queueing system.'
  s.author = 'David Selassie'
  s.email = 'selassid@gmail.com'
  s.homepage = 'http://github.com/selassid/cuted'

  s.files = ['lib/cuted/queue.rb', 'lib/cuted/command.rb']
  s.add_development_dependency 'riot', '~> 0.12'

  s.executables << 'cuted' << 'cute'
  s.add_runtime_dependency 'daemons', '~> 1.1'
  s.add_runtime_dependency 'trollop', '~> 1.16'
  s.add_runtime_dependency 'parseconfig', '~> 0.5'
  s.post_install_message = "Install optional gem 'prowler' for Prowl notifications when commands are complete."

end
