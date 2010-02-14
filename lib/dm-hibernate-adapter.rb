require 'hibernate'
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

module DataMapper
  module Adapters
    class HibernateAdapter < AbstractAdapter

      def initialize(name, options = {})
        super
        Hibernate.dialect = Hibernate::Dialects::HSQL
        Hibernate.current_session_context_class = "thread"
        
        Hibernate.connection_driver_class = "org.hsqldb.jdbcDriver"
        Hibernate.connection_url = "jdbc:hsqldb:file:jibernate"
        Hibernate.connection_username = "sa"
        Hibernate.connection_password = ""
        Hibernate.connection_pool_size = "1"
        Hibernate.properties["hbm2ddl.auto"] = "update"
        Hibernate.properties["show_sql"] = "true"
        Hibernate.properties["cache.provider_class"] = "org.hibernate.cache.NoCacheProvider"
      end

      # @param [Enumerable<Resource>] resources
      #   The list of resources (model instances) to create
      #
      # @return [Integer]
      #   The number of records that were actually saved into the data-store
      #
      # @api semipublic
      def create(resources)
        puts "create #{resources.inspect}"
        count = 0
        Hibernate.tx do |session|
          resources.each do |resource|
            session.save(resource)
            count += 1
          end
        end
        count
      end

      # @param [Query] query
      #   the query to match resources in the datastore
      #
      # @return [Enumerable<Hash>]
      #   an array of hashes to become resources
      #
      # @api semipublic
      def read(query)
        puts "query #{query.inspect}"
        result = []
        Hibernate.tx do |session|
          list = session.create_query("from #{query.model}").list
          #TODO maybe there is a direct way to get a ruby array ?
          list.each do |resource|
            result << resource
          end
          list
        end
        result
      end
    end
  end
end
