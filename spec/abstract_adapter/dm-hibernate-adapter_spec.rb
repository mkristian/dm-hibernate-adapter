
dir = Pathname(__FILE__).dirname.expand_path.to_s

require dir + '/spec_helper'

require dir + '/adapter_shared_spec'
require dir + '/hibernate_shared_spec'

describe DataMapper::Adapters::HibernateAdapter do
  DB_CONFIGS = {
          :H2_EMB     => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:jibernate" },
          :DERBY_EMB  => { :adapter => "hibernate", :dialect => "Derby", :url => "jdbc:derby:jibernate;create=true" },
          :HSQL_EMB   => { :adapter => "hibernate", :dialect => "HSQL", :username => "sa", :url => "jdbc:hsqldb:file:testdb;create=true" },
          :MySQL5     => { :adapter => "hibernate", :dialect => "MySQL5", :username => "root", :password => "root",
                           :url => "jdbc:mysql://localhost:3306/jibernate"},
          :PostgreSQL => { :adapter => "hibernate", :dialect => "PostgreSQL", :username => "postgres", :password => "postgres",
                           :url => "jdbc:postgresql://localhost:5432/jibernate"}
  }

  before :all do
    @adapter = DataMapper.setup(:default,DB_CONFIGS[:H2_EMB])
  end

  it_should_behave_like 'An Adapter'

  # TODO add hibernate/jruby specyfic specs
  it_should_behave_like 'An Hibernate Adapter'

end
