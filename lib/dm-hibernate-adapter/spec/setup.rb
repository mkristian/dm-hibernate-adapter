require 'dm-hibernate-adapter'
require 'dm-core/spec/setup'

module DataMapper
  module Spec
    module Adapters

      class HibernateAdapter < Adapter

        def setup!
          #adapter = DataMapper.setup(name, connection_uri)
          adapter = DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate")

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
