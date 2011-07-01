Jibernate/Hibernate module for DataMapper
=========================================

*WARNING* Don't use `-o` if you want to access remote repositories


### You have to:

    jruby -S gem install ruby-maven

setup the gems and compile the java extension. the second clean makes sure the newly built gem gets used.

    cd ../
    rmvn clean install -DskipSpecs -o
    cd demo
    rmvn clean

run rails webrick server (port: 3000)

    rmvn rails server -- -o

run rake

    rmvn rake  -- -o

run jetty servlet engine (http-port: 8080, https-port: 8443)

    jetty-run

### Note

the ruby-maven setup will generate a pom.xml which can be used by proper maven3.