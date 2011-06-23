Jibernate/Hibernate module for DataMapper
=========================================

You have to:
---------

    jruby -S gem install ruby-maven

setup the gems and compile the java extension

    rmvn clean gem:initialize compile

run the eventlog - list

    rmvn gem exec eventlog.rb list -- -o

run the eventlog - store

    rmvn gem exec eventlog.rb store something -- -o

run the eventlog - store with rollback

    rmvn gem exec eventlog.rb store_rollback something -- -o


Howtos:
----------

how to list rake tasks (please note the jruby.rake.args part(var name))

    rmvn rake -T -- -o

how to run specs?

  * AbstractAdapter specs:

        rmvn rake spec:adapter -- -o
	or
        rmvn test -- -Padapter -o

  * dm-core specs:

        rmvn rake spec:dm -- -o
	or
        rmvn test -- -Pdm -o

  * transient specs:

        rmvn rake spec:transient -- -o
	or
        rmvn test -- -Ptransient -o

to get debug output use (use '--' only once which denotes the beginning of maven options)

        -- -Djruby.verbose -e

you can switch the jruby version by adding to the above commands

        -- -Djruby.version=1.6.2

if you are getting OutOfMemory errors, you should try to tune jruby-maven-plugin's settings

        https://github.com/mkristian/jruby-maven-plugins

and set them as properties in 'Mavenfile' - see in that file
        properties['jruby.jvmargs'] = '-Xmx1024m'

if you are getting problems with specs you can skip that phase:

        -- -Dmaven.test.skip=true

Note
----

the ruby-maven setup will generate a pom.xml which can be used by proper maven3.