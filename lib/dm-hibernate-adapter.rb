require 'hibernate'
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

module DataMapper
  module Adapters
    class HibernateAdapter < AbstractAdapter

      def initialize(name, options = {})
        super
        Hibernate.dialect = Hibernate::Dialects::H2
        Hibernate.current_session_context_class = "thread"
        
        Hibernate.connection_driver_class = "org.h2.Driver"
        Hibernate.connection_url = "jdbc:h2:jibernate"
        Hibernate.connection_username = "sa"
        Hibernate.connection_password = ""
        Hibernate.connection_pool_size = "1"
        Hibernate.properties["hbm2ddl.auto"] = "update"
        Hibernate.properties["format_sql"] = "false"
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
        log_read(query)
        conditions = query.conditions

        result = []
        Hibernate.tx do |session|
          #TODO add support for 'where'
          list = session.create_query("from #{query.model}").list
          #TODO maybe there is a direct way to get a ruby array ?
          list.each do |resource|
            result << resource
          end
          list
        end
        result
      end

      def delete(resources)
        resources.each do |resource|
          puts "deleting #{resource.inspect}"
          Hibernate.tx do |session|
            session.delete(resource)
          end
        end
        resources.size
      end

# helper methods - printers
private
def log_read(query)
puts <<EOT
  read()
    query:
      #{query.inspect}
    model:
      #{query.model}
    conditions:
      #{query.conditions}
EOT
end

    end
  end
end
