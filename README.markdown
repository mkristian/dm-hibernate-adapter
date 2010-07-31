Jibernate/Hibernate module for DataMapper
=========================================

Some info
---------

There will be info

Howtos
---------

need to install maven3 (just grab it from http://www.maven.apache.org/download.html and change executable's name to mvn3)

setup the gems

    mvn3 clean gem:initialize

run the eventlog - list

    mvn3 ruby:jruby -Djruby.args="eventlog.rb list"

run the eventlog - store

    mvn3 ruby:jruby -Djruby.args="eventlog.rb store something"

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

TODOs
---------

- add support for regexps (add custom sql function for Derby http://db.apache.org/derby/docs/10.5/ref/rrefcreatefunctionstatement.html,
  use hsqldb 2.0.0.rc8 (regexps) http://www.reverttoconsole.com/blog/java/upgrading-to-hsqldb-2rc8-part-1-maven-integration)
- enhance queries support: (join(links), group by + having, raw queries, one row in RS, subqueries in raw queries)
- add more specs for adapter
- add specs for hibernate/jruby specific stuff
- add metrics tool (test coverage etc)
- add more supported types
- refactor classes structure
- improve adapter 'automagic' (ie. remove #hibernate! or all the helper methods)
- add support for auto_migrate! (https://www.hibernate.org/hib_docs/v3/api/org/hibernate/tool/hbm2ddl/SchemaUpdate.html) on the adapter and better support on the model
- add more ability to configure adapter (other dbs, hibernate specific configuration)
- add docs
- add examples
- make a gem (wait until there are maven gems of jar artifacts available)
- obey the properties field and required constraints as well the storagename for the tablename
- make sure logger logs with a block to avoid unnessecary string operations, i.e @@logger.debug { "some " + exception + " something" }
- remove all dirty hacks from jibernate (ie.  Resource#send can't be used )
- transactions for the adapter