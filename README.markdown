Jibernate/Hibernate module for DataMapper
=========================================

You have to:
---------

install maven3 (http://www.maven.apache.org/download.html)

setup the gems

    mvn clean gem:initialize

run the eventlog - list

    mvn ruby:jruby -Dargs="eventlog.rb list"

run the eventlog - store

    mvn ruby:jruby -Dargs="eventlog.rb store something"

run the eventlog - store with rollback

    mvn ruby:jruby -Dargs="eventlog.rb store_rollback something"


Howtos:
----------

how to list rake tasks (please note the jruby.rake.args part(var name))

    mvn ruby:jruby -Dargs="-S rake -T"

how to run specs?

  * AbstractAdapter specs:

        mvn ruby:jruby -e -Djruby.verbose=true -Dargs="-S rake spec:adapter"
	or
        mvn test -e -Djruby.verbose=true -Padapter

  * dm-core specs:

        mvn ruby:jruby -e -Djruby.verbose=true -Dargs="-S rake spec:dm"
	or
        mvn test -e -Djruby.verbose=true -Pdm

  * transient specs:

        mvn ruby:jruby -e -Djruby.verbose=true -Dargs="-S rake spec:transient"
	or
        mvn test -e -Djruby.verbose=true -Ptransient

you can switch the jruby version by adding to the above commands

        -Djruby.version=1.5.3

if you are getting OutOfMemory errors, you should try to tune jruby-maven-plugin's settings

        https://github.com/mkristian/jruby-maven-plugins

if you are getting problems with specs you can skip that phase:

        -Dmaven.test.skip=true


Rails 2.3.5 demo
----------------

start the server with
        mvn rails2:server
and point your browser to
        http://localhost:3000/users
or
        http://localhost:3000/maven.html
