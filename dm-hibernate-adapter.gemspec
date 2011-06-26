# create by maven - leave it as is
Gem::Specification.new do |s|
  s.name = 'dm-hibernate-adapter'
  s.version = '0.1'

  s.summary = 'dm-hibernate-adapter'


  s.platform = 'java'
  s.files = Dir['lib/dm-hibernate-adapter_ext.jar']
  s.files += Dir['lib/dm-hibernate-adapter.rb']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  DM_VERSION = '~> 1.0.0'
  s.add_dependency 'dm-core', DM_VERSION
  s.add_dependency 'dm-transactions', DM_VERSION
  s.add_dependency 'dm-migrations', DM_VERSION
  s.add_dependency 'slf4r', '0.3.1'
  s.add_development_dependency 'yard', '0.5.3'
  s.add_development_dependency 'rake', '0.8.7'
  s.add_development_dependency 'rspec', '1.3.0'
  s.add_development_dependency 'ruby-maven', '0.8.3.0.3.0.28.1'
  s.requirements << File.read('Mavenfile')
end
