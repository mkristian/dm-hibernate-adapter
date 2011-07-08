# -*- mode: ruby -*-
jar "org.hibernate:hibernate-core", "3.3.2.GA"
jar "org.hibernate:hibernate-annotations", "3.4.0.GA"
jar "org.hibernate:hibernate-tools", "3.2.4.GA"
jar "javax.transaction:jta", "1.1"
jar 'javassist:javassist', '3.8.0.GA'
jar 'mysql:mysql-connector-java', '5.1.9'
jar 'postgresql:postgresql', '8.4-701.jdbc4'
jar 'com.h2database:h2', '1.2.138'
jar 'org.apache.derby:derby' ,'10.5.3.0_1'
jar 'org.hsqldb:hsqldb', '2.0.0'

# not sure of this is needed
#jar 'org.jruby:jruby-complete', '1.6.2'

test_jar 'org.slf4j:slf4j-log4j12', '1.5.2'
test_jar 'log4j:log4j', '1.2.14'

repository(:jboss).url 'https://repository.jboss.org/nexus/content/groups/public-jboss/'

properties['jruby.jvmargs'] = '-Xmx1024m'

packaging 'java-gem'

build.final_name '${project.artifactId}_ext'

plugin(:gem).configuration[:includeOpenSSL] = false

profile(:transient) do |t|
  t.plugin(:rspec).configuration[:specSourceDirectory] = 'spec/transient'
end

profile(:adapter) do |t|
  t.plugin(:rspec).configuration[:specSourceDirectory] = 'spec/abstract_adapter'
end

profile(:dm) do |t|
  t.plugin(:rspec).configuration[:specSourceDirectory] = 'spec/dm_core'
end

execute_in_phase(:initialize) do
  require 'fileutils'
  FileUtils.cp("dm-hibernate-adapter.gemspec.pom", "pom.xml")
end
