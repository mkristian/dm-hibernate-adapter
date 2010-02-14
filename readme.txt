# need to install maven3 (just grab it from http://www.maven.apache.org/download.html and change executable's name to mvn3)

# setup the gems
mvn3 gem:initialize

# run the eventlog - list
mvn3 ruby:jruby -Djruby.args="eventlog.rb list"

# run the eventlog - store
mvn3 ruby:jruby -Djruby.args="eventlog.rb store something"

# maybe you need to replace ther respective line in jibernate.script with
SET WRITE_DELAY 0 MILLIS

