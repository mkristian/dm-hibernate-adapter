# need to install maven3 (maven.apache.org/download.html)

# setup the gems
mvn gem:initialize 

# run the eventlog - list
mvn ruby:jruby -Djruby.args="eventlog.rb list"

# run the eventlog - store
mvn ruby:jruby -Djruby.args="eventlog.rb store something"

# maybe you need to replace ther respective line in jibernate.script with
SET WRITE_DELAY 0 MILLIS

