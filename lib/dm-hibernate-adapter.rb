require 'java'
begin
  require 'dm-hibernate-adapter_ext.jar'
rescue LoadError
  warn "missing extension jar, may be it is already in the parent classloader"
end
java_import 'de.saumya.jibernate.UpdateWork'
require 'slf4r'
require 'slf4r/java_logger'

if require 'dm-core'
  DataMapper.logger = Slf4r::LoggerFacade.new(DataMapper)
end

require 'dm-core/adapters/abstract_adapter'

require 'jruby/core_ext'
require 'stringio'

require 'dm-hibernate-adapter/dialects'
require 'dm-hibernate-adapter/hibernate'
require 'dm-hibernate-adapter/transaction'


module DataMapper
  module Adapters

    java_import org.hibernate.criterion.Restrictions # ie. Restriction.eq
    java_import org.hibernate.criterion.Order        # ie. Order.asc

    class HibernateAdapter < AbstractAdapter

      @@logger = Slf4r::LoggerFacade.new(HibernateAdapter)

      DRIVERS = {
        :H2             => "org.h2.Driver",
        :HSQL           => "org.hsqldb.jdbcDriver",
        :Derby          => "org.apache.derby.jdbc.EmbeddedDriver",
        :MySQL5         => "com.mysql.jdbc.Driver",
        :MySQL5InnoDB   => "com.mysql.jdbc.Driver",
        :MySQL          => "com.mysql.jdbc.Driver",
        :MySQLInnoDB    => "com.mysql.jdbc.Driver",
        :MySQLMyISAM    => "com.mysql.jdbc.Driver",
        :PostgreSQL     => "org.postgresql.Driver",
      }

      DataMapper::Model.append_inclusions( Hibernate::Model )

      extend( Chainable )

      def initialize(name, options = {})
        dialect   = options.delete(:dialect)
        username  = options.delete(:username)
        password  = options.delete(:password)
        driver    = options.delete(:driver)    || DRIVERS[dialect.to_sym]
        pool_size = options.delete(:pool_size) || "1"
        url       = options.delete(:url)
        url      += "jdbc:" unless url =~ /^jdbc:/

        super( name, options )

        Hibernate.dialect = Hibernate::Dialects.const_get(dialect.to_s)
        Hibernate.current_session_context_class = "thread"
        
        Hibernate.connection_driver_class = driver.to_s
        Hibernate.connection_url          = url.to_s # ie. "jdbc:h2:jibernate"
        Hibernate.connection_username     = username.to_s # ie. "sa"
        Hibernate.connection_password     = password.to_s # ie. ""
        Hibernate.connection_pool_size    = pool_size.to_s

        Hibernate.properties["cache.provider_class"]  = "org.hibernate.cache.NoCacheProvider"
        Hibernate.properties["hbm2ddl.auto"]          = "update"
        Hibernate.properties["format_sql"]            = "false"
        Hibernate.properties["show_sql"]              = "true"

      end

      # @param [Enumerable<Resource>] resources
      #   The list of resources (model instances) to create
      #
      # @return [Integer]
      #   The number of records that were actually saved into the data-store
      #
      # @api semipublic
      def create(resources)
        @@logger.debug("create #{resources.inspect}")
        count = 0
        unit_of_work do |session|

           resources.each do |resource|
            begin
              session.persist(resource)
              count += 1
            rescue NativeException => e
              @@logger.debug("error creating #{resource.inspect()}", e.cause())
              session.clear()
              raise e
            end
          end
        end
        count
      end

      # @param [Hash(Property => Object)] attributes
      #   hash of attribute values to set, keyed by Property
      # @param [Collection] collection
      #   collection of records to be updated
      #
      # @return [Integer]
      #   the number of records updated
      #
      # @api semipublic
      def update(attributes, collection)
        
        log_update(attributes, collection)
        count = 0
        unit_of_work do |session|
          collection.each do |resource|
            session.update(resource)
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
        model      = query.model
        limit      = query.limit
        offset     = query.offset
        order      = query.order

        result = []

        unit_of_work do |session|

          criteria = session.create_criteria(model.to_java_class_name)
          # where ...
          criteria.add(parse_conditions_tree(conditions,model))  unless conditions.nil?
          # limit ...
          criteria.set_max_results(limit) unless limit.nil?
          # offset
          criteria.set_first_result(offset) unless offset.nil?
          # order by
          unless order.nil?
          order.each do |direction|
            operator = direction.operator
            # TODO column name may differ from property name
            column = direction.target.name
            if operator == :desc
              order  = Order.desc(column.to_s.to_java_string)
            else
              order  = Order.asc(column.to_s.to_java_string)
            end

            criteria.add_order(order)
            end
          end            

          @@logger.debug(criteria.to_s)

          # TODO handle exceptions
          result = criteria.list

        end
        result.to_a
      end

      # @param [Collection] collection
      #   collection of records to be deleted
      #
      # @return [Integer]
      #   the number of records deleted
      #
      # @api semipublic
      def delete(resources)

        unit_of_work do |session|
          resources.each do |resource|
            @@logger.debug("deleting #{resource.inspect}")
              session.delete(resource)
          end
        end
        resources.size
      end

      # extension to the adapter API

      def execute_update(sql)

        unit_of_work do |session|
          session.do_work(UpdateWork.new(sql))
        end
      end

      # <dm-transactions>
  
      # Produces a fresh transaction primitive for this Adapter
      #
      # Used by Transaction to perform its various tasks.
      #
      # @return [Object]
      #   a new Object that responds to :close, :begin, :commit,
      #   and :rollback,
      #
      # @api private
      def transaction_primitive()
        # DataObjects::Transaction.create_for_uri(normalized_uri)
        Hibernate::Transaction.new()
      end

      # Pushes the given Transaction onto the per thread Transaction stack so
      # that everything done by this Adapter is done within the context of said
      # Transaction.
      #
      # @param [Transaction] transaction
      #   a Transaction to be the 'current' transaction until popped.
      #
      # @return [Array(Transaction)]
      #   the stack of active transactions for the current thread
      #
      # @api private
      #
      def push_transaction(transaction)
        transactions() << transaction
      end

      # Pop the 'current' Transaction from the per thread Transaction stack so
      # that everything done by this Adapter is no longer necessarily within the
      # context of said Transaction.
      #
      # @return [Transaction]
      #   the former 'current' transaction.
      #
      # @api private
      def pop_transaction()
        transactions().pop()
      end


      # Retrieve the current transaction for this Adapter.
      #
      # Everything done by this Adapter is done within the context of this
      # Transaction.
      #
      # @return [Transaction]
      #   the 'current' transaction for this Adapter.
      #
      # @api private
      def current_transaction()
        transactions().last()
      end
      
      # </dm-transactions>

      
      
        private

        # @api private
        def transactions()
          Thread.current[:dm_transactions]            ||= {}
          Thread.current[:dm_transactions][object_id] ||= []
        end

        def unit_of_work( &block )
          # TODO state of the session should be also checked!
          current_tx = current_transaction()

          if current_tx
            block.call( current_tx.primitive_for( self ).session() )
          else
            Hibernate.tx( &block )
          end
        end

        def cast_to_hibernate (value, model_type)
          #TODO ADD MORE TYPES!!!
          case value
            when Fixnum
              # XXX Warning. ie Integer.value_of(value) returns cached objects already converted to Ruby objects!
              if    model_type == Java::JavaLang::Integer then java.lang.Integer.new(value)
              elsif model_type == Java::JavaLang::Long    then java.lang.Long.new(value)
              else  puts "---other Hibernate type, object: #{value} type: #{value.class} Hibernate type: #{model_type} ---"
              end
            when Float    then java.lang.Float.new(value)
            when String   then value.to_java_string
            when Array
              # if there is WHERE x IN ( ) -> WHERE x IN ( null ) should be used
              value = [nil] if value.empty?
              (value.map{|object| cast_to_hibernate(object, model_type)}).to_java
            when Range    then (value.to_a.map{|object| cast_to_hibernate(object, model_type)}).to_java
            when NilClass then nil
            when Regexp   then value.source.to_java_string
            else
              puts "---other Ruby type, object: #{value} type: #{value.class} ---"
              value.to_s.to_java_string
          end
        end

        def handle_comparison(con, model)
          subject = nil
          value   = nil

          case con.subject
          when DataMapper::Property
            subject = con.subject.name.to_s # property/column name
            value = con.value # value used in comparison
          when DataMapper::Associations::ManyToOne::Relationship
            # TODO allow multicolumn keys !!!
            subject = con.subject.parent_key.first.name.to_s
            value = con.subject.parent_key.get(con.value).first # value used in comparison
          when DataMapper::Associations::OneToMany::Relationship
            # TODO allow multicolumn keys !!!
            # TODO why the break in symetry ?
            subject = con.subject.parent_key.first.name.to_s
            # why does is not work: con.subject.child_key.get(con.value).first ???
            value = con.subject.child_key.first.get(con.value.first) # value used in comparison
          end
          model_type = model.to_java_type(model.properties[subject.to_sym].class) # Java type of property (used in typecasting)
          dialect = Hibernate.dialect # SQL dialect for current configuration

          case con
            when DataMapper::Query::Conditions::EqualToComparison
              # special case handling IS NULL/ NOT (x IS NULL)
              value.class == NilClass ? Restrictions.isNull(subject) :
                                        Restrictions.eq(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::GreaterThanComparison
              Restrictions.gt(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::LessThanComparison
              Restrictions.lt(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::LikeComparison
              Restrictions.like(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::GreaterThanOrEqualToComparison
              Restrictions.ge(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::LessThanOrEqualToComparison
              Restrictions.le(subject, cast_to_hibernate(value, model_type))

            when DataMapper::Query::Conditions::InclusionComparison
              if value.class == Array
                # special case handling :x => 1..110 / :x => [1,2,3]
                Restrictions.in(subject, cast_to_hibernate(value, model_type))
              else
                # XXX proper ordering?
                arr = value.is_a?(Fixnum) ? [value] : value.to_a
                lo = arr.first
                hi = arr.last
                if lo.nil? || hi.nil?
                  Restrictions.in(subject, cast_to_hibernate(value, model_type))
                else
                  Restrictions.between(subject, cast_to_hibernate(lo, model_type), cast_to_hibernate(hi, model_type))
                end
              end

            when DataMapper::Query::Conditions::RegexpComparison

              if dialect == "org.hibernate.dialect.HSQLDialect"
                Restrictions.sqlRestriction("(regexp_matches (" +subject + ", ?))",
                             cast_to_hibernate(value, model_type), org::hibernate::Hibernate::STRING)
              elsif dialect == "org.hibernate.dialect.PostgreSQLDialect"
                Restrictions.sqlRestriction("(" + subject +" ~ ?)",
                             cast_to_hibernate(value, model_type), org::hibernate::Hibernate::STRING)
              # elsif dialect ==  "org.hibernate.dialect.DerbyDialect"
              # TODO implement custom matching function for some dbs (see README on Wiki)
              else
                Restrictions.sqlRestriction("(" + subject +" regexp ?)",
                             cast_to_hibernate(value, model_type), org::hibernate::Hibernate::STRING)
              end

          end
        end

        def parse_all_children(children, model, operand)
          operand = children.inject(operand){ |op,child| op.add(parse_conditions_tree(child, model))}
        end

        def parse_the_only_child(child,model)
          parse_conditions_tree(child, model)
        end

        def handle_operation(con, model)
          children = con.children

          case con
            when DataMapper::Query::Conditions::AndOperation
              parse_all_children(children, model, Restrictions.conjunction())

            when DataMapper::Query::Conditions::OrOperation
              parse_all_children(children, model, Restrictions.disjunction())

            when DataMapper::Query::Conditions::NotOperation
              #XXX only one child may be negated in DM?
              child = children.first

              if !(child.respond_to? :children) &&
                  (child.class == DataMapper::Query::Conditions::InclusionComparison) &&
                  (child.value.class == Array)  && (child.value.empty?)

                subject = child.subject.name.to_s
                # XXX ugly workaround for Model.all(:x.not => [])
                Restrictions.sqlRestriction(" ( "+ subject +" is null or " + subject +" is not null ) ")
              else
                Restrictions.not(parse_the_only_child(child,model))
              end

            when DataMapper::Query::Conditions::NullOperation
              # XXX NullOperation is not used in dm_core at the moment
              raise NotImplementedError, "#{con.class} is not not used in dm_core"
          end
        end

        def parse_conditions_tree(conditions, model)
          #conditions has children ? (in fact -> "is it comparison or operand?")
          unless conditions.respond_to?(:children)
            handle_comparison(conditions, model)
          else
            handle_operation(conditions, model)
          end
        end

        # -----  helper methods - printers -----

        # @param [Query] query
        #   the query to print it out formatted
        #
        # @api private
        def log_read(query)
          @@logger.debug <<-EOT
          read()
              query:
                #{query.inspect}
              model:
                #{query.model}
              conditions:
                #{query.conditions}
          EOT
        end

        # @param [Hash(Property => Object)] attributes
        #   hash of attribute values to print it out formatted, keyed by Property
        # @param [Collection] collection
        #   collection of records to print it out formatted
        #
        # @api private
        def log_update(attributes,collection)
          @@logger.debug <<-EOT
          update()
             attributes:
               #{attributes.inspect}
             collection:
               #{collection.inspect}
          EOT
        end

    end
  end
end
