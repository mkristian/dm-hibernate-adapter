require 'java'

org.apache.log4j.PropertyConfigurator.configure(File.dirname(__FILE__) + '/../log4j.properties')

require 'rubygems'
require 'spec'

require 'dm-hibernate-adapter'

dir = Pathname(__FILE__).dirname.expand_path.to_s

Dir[dir + "/lib/*.rb"].each{ |file| require dir+"/lib/" + File.basename(file, File.extname(file))}


