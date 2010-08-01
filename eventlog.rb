require 'rubygems'
require 'lib/dm-hibernate-adapter.rb'
#require 'dm-transactions'

DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/eventlog")

class Event
  include DataMapper::Resource
  
  property :id,    Serial
  property :title, String, :required => true, :length => 10
  property :date,  Date

end

if File.exists?("target/eventlog.h2.db")
  Event.auto_upgrade!
else
  Event.auto_migrate!
end

case ARGV[0]
when /store_update/
  # Create event and store it, then it's updated
  event = Event.new
  event.title = ARGV[1]
  event.date = java.util.Date.new
  event.save
  puts "Stored!"
  event.update(:title =>ARGV[2])
  puts "Updated!"
when /store/
  # Create event and store it

  #DataMapper::Transaction.new(DataMapper.repository(:default)).commit do
    #raise "rollack it!"

    event = Event.new
    event.title = ARGV[1]
    event.date = Date.today
    event.save

  #end
  puts "Stored!"
when /update/
   # Update event and store it
   event = Event.get(ARGV[1])
   event.title = ARGV[2]
   event.save
   puts "Updated!"
when /list/
  list = Event.all
  puts "Listing all events #{list.size}:"
  list.each do |evt|
    puts <<EOS
  id: #{evt.id}
    title: #{evt.title}
    date: #{evt.date}
EOS
  end
else
  puts "Usage:\n\tstore <title>\n\tstore_update <title> <title2>\n\tlist"
end

