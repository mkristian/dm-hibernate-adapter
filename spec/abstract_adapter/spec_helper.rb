require 'java'

org.apache.log4j.PropertyConfigurator.configure(File.dirname(__FILE__) + '/../log4j.properties')

require 'rubygems'
require 'spec'

require 'dm-hibernate-adapter'
