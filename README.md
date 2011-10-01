dm-hibernate-adapter aka jibernate
=========================================


Installation:
-------------

    jruby -S gem install ruby-maven

setup the gems and compile the java extension

    rmvn clean gem:initialize compile -- -Djruby.version=1.6.4

ruby-maven
----------

* The ruby-maven setup will generate a pom.xml which can be used by proper maven3.
* Don't use `-o` if you want to access remote repositories

Logging
-------

* use `SHOW_SQL=true` ENV variable in order to log SQL (except DDL, turned off by default)
* use `FORMAT_SQL=true` ENV variable in order to format SQL logs

Howtos:
-------

### how to test basic actions with `eventlog.rb`

* how to run the eventlog - listing

    `rmvn gem exec eventlog.rb list -- -o -Djruby.version=1.6.4`

* how to run the eventlog - storing record

    `rmvn gem exec eventlog.rb store something -- -o -Djruby.version=1.6.4`

* how to run the eventlog - storing with rollback

    `rmvn gem exec eventlog.rb store_rollback something -- -o -Djruby.version=1.6.4`

* how to list rake tasks (please note the jruby.rake.args part(var name))

    `rmvn rake -T -- -o`

### Specs

* AbstractAdapter specs:

  `rmvn rake spec:adapter -- -o`
or
  `rmvn test -- -Padapter -o`

* dm-core specs:

  `rmvn rake spec:dm -- -o`
or
  `rmvn test -- -Pdm -o`

* transient specs:

  `rmvn rake spec:transient -- -o`
or
  `rmvn test -- -Ptransient -o`

when using `rmvn test` there will be a nice html rspec report in **target/rspec-report.html**.
to get debug output use (use '--' only once which denotes the beginning of maven options)

  `-- -Djruby.verbose -e`

you can switch the jruby version by adding to the above commands

  `-- -Djruby.version=1.6.3`

if you are getting OutOfMemory errors, you should try to tune jruby-maven-plugin's [settings](https://github.com/mkristian/jruby-maven-plugins) and set them as properties in 'Mavenfile' - see in that file

  `properties['jruby.jvmargs'] = '-Xmx1024m'`

if you are getting problems with specs you can skip that phase:

  `-- -Dmaven.test.skip=true`


Authors
-------

Authors listed in `dm-hibernate-adapter.gemspec` file (in random order).
Project was built on top of Charles Nutter's sample code.

License
-------

See `LICENSE.md`



