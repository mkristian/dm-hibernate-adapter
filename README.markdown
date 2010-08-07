Jibernate/Hibernate module for DataMapper
=========================================

You have to:
---------

install maven3 (just grab it from http://www.maven.apache.org/download.html and change executable's name to mvn3)

setup the gems

    mvn3 clean gem:initialize

run the eventlog - list

    mvn3 ruby:jruby -Djruby.args="eventlog.rb list"

run the eventlog - store

    mvn3 ruby:jruby -Djruby.args="eventlog.rb store something"
    
run the eventlog - store with rollback

    mvn3 ruby:jruby -Djruby.args="eventlog.rb store_rollback something"


Howtos:
----------

how to list rake tasks (please note the jruby.rake.args part(var name))

    mvn3 ruby:jruby -Djruby.args="-S rake -T"

how to run specs?

  * AbstractAdapter specs:

        mvn3 ruby:jruby -e -Djruby.verbose=true -Djruby.args="-S rake spec:adapter"
	or
        mvn3 test -e -Djruby.verbose=true -Padapter

  * dm-core specs:

        mvn3 ruby:jruby -e -Djruby.verbose=true -Djruby.args="-S rake spec:dm"
	or
        mvn3 test -e -Djruby.verbose=true -Pdm

  * transient specs:

        mvn3 ruby:jruby -e -Djruby.verbose=true -Djruby.args="-S rake spec:transient"
	or
        mvn3 test -e -Djruby.verbose=true -Ptransient

you can switch the jruby version by adding to the above commands

        -Djruby.version=1.4.1

Rails 2.3.5 demo
----------------

start the server with
        mvn3 rails2:server
and point your browser to
        http://localhost:3000/users
or
        http://localhost:3000/maven.html
