Jibernate/Hibernate module for DataMapper
=========================================

*WARNING* Don't use `-o` if you want to access remote repositories


### You have to:

    jruby -S gem install ruby-maven

setup the gems and compile the java extension. the second clean makes sure the newly built gem gets used.

    cd ../
    rmvn clean install -DskipSpecs -o -Djruby.version=1.6.4
    cd demo

and on unix/linux box you can set the PATH variable like

   export PATH=./target/bin:$PATH

which allows you to use binstubs from rubygems wrapped with a classpath after

   rmvn clean
   rmvn bundle install

*NOTE:* make sure you have jruby version 1.6.4 or higher in your $PATH. any hint how this works with __rvm__ is welcome

run first to create an emtpy database

    rake db:automigrate

    or
 
    rmvn rake db:automigrate
    
run rails webrick server (port: 3000)

    rails server

    or 

    rmvn rails server -- -o -Djruby.version=1.6.4

run rake

    rake

    or

    rmvn rake  -- -o -Djruby.version=1.6.3

run jetty servlet engine (http-port: 8080, https-port: 8443)

    jetty-run

### Note

the ruby-maven setup will generate a Gemfile.pom which can be used by proper maven3.
