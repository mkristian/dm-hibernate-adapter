require 'rubygems'
require 'lib/dm-hibernate-adapter.rb'

DataMapper.setup(:default, :adapter => "hibernate")

class Event
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String
  property :date, Date

  # TODO make it automagic
  hibernate!
end

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

