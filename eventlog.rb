# Basic requires
require 'rubygems'
require 'java'
require 'jruby/core_ext'
require 'dm-core'

require 'lib/dm-hibernate-adapter.rb'
DataMapper.setup(:default, :adapter => "hibernate")

class Event
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String
  property :date, Date

  # TODO get this out of the model into the adapter 
  extend Hibernate::Model
  hibernate_attr :title => :string, :date => :date
  hibernate_identifier :id, :long
  hibernate!
end

# Hack for HSQLDB's write delay
#  session.createSQLQuery("SET WRITE_DELAY FALSE").execute_update

case ARGV[0]
when /store/
  # Create event and store it
  event = Event.new
  event.title = ARGV[1]
  event.date = java.util.Date.new
  event.save
  puts "Stored!"
when /list/
  list = Event.all
  puts "Listing all events:"
  list.each do |evt|
    puts <<EOS
  id: #{evt.id}
    title: #{evt.title}
    date: #{evt.date}
EOS
  end
else
  puts "Usage:\n\tstore <title>\n\tlist"
end

