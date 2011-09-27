require 'rubygems'
require 'lib/dm-hibernate-adapter.rb'
require 'dm-transactions'

DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/eventlog")

class Event
  include DataMapper::Resource

  property :id,    Serial
  property :title, String, :required => true, :length => 10
  property :date,  Date

  has n,   :people
end

class Person
  include DataMapper::Resource

  property :id,    Serial
  property :name,  String, :required => true

  belongs_to :event
end

if File.exists?("target/eventlog.h2.db")
  Event.auto_upgrade!
  Person.auto_upgrade!
else
  Event.auto_migrate!
  Person.auto_migrate!
end

case ARGV[0]
when /store_update/
  # Create event and store it, then it's updated
  event = Event.new
  event.title = ARGV[1]
  event.date = java.util.Date.new
  event.save
  event.update(:title =>ARGV[2])

when /store_rollback/
  Event.transaction do |tx|

    event = Event.new
    event.title = ARGV[1]
    event.date = Date.today
    event.save

    tx.rollback
  end

when /store_both/
  event = Event.new
  event.title = ARGV[1]
  event.date = Date.today
  event.save

  ARGV[2].to_i.times do |i|
    person = event.people.new( :name => "John##{i}" )
    person.save
  end


when /store/
  event = Event.new
  event.title = ARGV[1]
  event.date = Date.today
  event.save

when /update/
   # Update event and store it
   event = Event.get(ARGV[1])
   event.title = ARGV[2]
   event.save

when /list/
  list = Event.all
  puts "Listing all events #{list.size} with people:"
  list.each do |evt|
    puts <<-EOS
    Event:
    =============
    id: #{evt.id}
    title: #{evt.title}
    date: #{evt.date}
    inspect: #{evt.inspect}
    EOS
    evt.people do |p|
    puts <<-EOS
    Person:
    ===========
    id: #{p.id}
    name: #{p.name}
    event: #{p.event}
    inspect: #{p.inspect}
    EOS
    end
  end

  list = Person.all
  puts "\nListing all people #{list.size}:"
  list.each do |p|
    puts <<-EOS
    Person:
    ===========
    id: #{p.id}
    name: #{p.name}
    event: #{p.event}
    inspect: #{p.inspect}
    EOS
  end

else
  puts "Usage:\n\tstore <title>\n\tstore_update <title> <title2>\n\tlist"
end

