require 'dm-hibernate-adapter'
require 'dm-core/spec/setup'

DB_CONFIGS = {
  :H2_EMB     => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate" },
  :DERBY_EMB  => { :adapter => "hibernate", :dialect => "Derby", :url => "jdbc:derby:target/jibernate;create=true" },
  :HSQL_EMB   => { :adapter => "hibernate", :dialect => "HSQL", :username => "sa", :url => "jdbc:hsqldb:file:target/testdb;create=true" },
  :MySQL5     => { :adapter => "hibernate", :dialect => "MySQL5", :username => "root", :password => "root",
                   :url => "jdbc:mysql://localhost:3306/jibernate"},
  :PostgreSQL => { :adapter => "hibernate", :dialect => "PostgreSQL", :username => "postgres", :password => "postgres",
                   :url => "jdbc:postgresql://localhost:5432/jibernate"}
}

module DataMapper
  module Spec
    module Adapters

      class HibernateAdapter < Adapter

        def setup!
          adapter = DataMapper.setup(:default, DB_CONFIGS[(ENV['DIALECT'] || :H2_EMB).to_sym])

          test_connection(adapter)
          adapter
        rescue Exception => e
          puts "Could not connect to the database using '#{connection_uri}' because of: #{e.inspect}"
        end

      end

      use HibernateAdapter
    end
  end
end

