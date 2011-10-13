# -*- coding: utf-8 -*-
require 'fileutils'
Gem::Specification.new do |s|
  s.name = 'dm-hibernate-adapter'
  s.version = '0.3pre'

  s.summary = 'dm-hibernate-adapter'

  s.authors = ['Douglas Ferreira', 'Kristian Meier', 'Piotr Gęga']
  s.email = ['douglasrodrigo@gmail.com', 'm.kristian@web.de', 'piotrgega@gmail.com']

  s.platform = 'java'

  # copy the jar file into place !!!
  FileUtils.cp('target/dm-hibernate-adapter_ext.jar', 'lib') if File.exists?('target/dm-hibernate-adapter_ext.jar')

  s.files = Dir['lib/dm-hibernate-adapter_ext.jar']
  s.files += Dir['lib/dm-hibernate-adapter.rb']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  DM_VERSION = '~> 1.1.0'
  s.add_dependency 'dm-core', DM_VERSION
  s.add_dependency 'dm-transactions', DM_VERSION
  s.add_dependency 'dm-migrations', DM_VERSION
  s.add_dependency 'slf4r', '0.3.1'
  s.add_development_dependency 'yard', '0.5.3'
  s.add_development_dependency 'rake', '0.9.2'
  s.add_development_dependency 'rspec', '1.3.0'
  s.add_development_dependency 'ruby-maven', '3.0.3.0.28.5'
  s.add_development_dependency 'jruby-openssl', '0.7.4'
  s.requirements << File.read('Mavenfile')
end
