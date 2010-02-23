Jibernate/Hibernate module for DataMapper
=========================================

Some info
---------

There will be info

Howtos
---------

need to install maven3 (just grab it from http://www.maven.apache.org/download.html and change executable's name to mvn3)

setup the gems

    mvn3 gem:initialize

run the eventlog - list

    mvn3 ruby:jruby -Djruby.args="eventlog.rb list"

run the eventlog - store

    mvn3 ruby:jruby -Djruby.args="eventlog.rb store something"

how to list rake tasks (please note the jruby.rake.args part(var name))

    mvn3 ruby:rake -Djruby.rake.args="-T"

how to run specs?

    mvn3 ruby:rake -e -Dverbose=true -Djruby.rake.args="spec"

TODOs
---------

- add support for 'between' instead of 'in' for Ranges
- add support for "empty sets" (done)
- add support for regexps (add custom sql function for Derby http://db.apache.org/derby/docs/10.5/ref/rrefcreatefunctionstatement.html,
  use hsqldb 2.0.0.rc8 (regexps) http://www.reverttoconsole.com/blog/java/upgrading-to-hsqldb-2rc8-part-1-maven-integration)
- enhance queries support: (join(links), group by + having, raw queries, one row in RS, subqueries in raw queries)
- add more specs for adapter
- add specs for hibernate specific stuff
- add metrics tool (test coverage etc)
- add more supported types
- refactor classes structure
- make adapter 'automagic' (ie. remove #hibernate!)
- add support for auto_migrate! (https://www.hibernate.org/hib_docs/v3/api/org/hibernate/tool/hbm2ddl/SchemaUpdate.html)
- add ability to configure adapter (other dbs, hibernate specific configuration)
- add docs
- add examples
- make a gem
