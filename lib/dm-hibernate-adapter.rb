require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

require 'java'
require 'jruby/core_ext'
require 'stringio'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-hibernate-adapter'

require dir / 'dialects'
require dir / 'hibernate'

module DataMapper
  module Adapters

    java_import org.hibernate.criterion.Restrictions # ie. Restriction.eq
    java_import org.hibernate.criterion.Order # ie. Order.asc

    class HibernateAdapter < AbstractAdapter

      # TODO maybe more drivers (Oracle, SQLITE3)
      DRIVERS = {
        :H2 => "org.h2.Driver",
        :HSQL => "org.hsqldb.jdbcDriver",
        :Derby => "org.apache.derby.jdbc.EmbeddedDriver",
        :MySQL5 => "com.mysql.jdbc.Driver",
        :MySQL5InnoDB => "com.mysql.jdbc.Driver",
        :MySQL => "com.mysql.jdbc.Driver",
        :MySQLInnoDB => "com.mysql.jdbc.Driver",
        :MySQLMyISAM => "com.mysql.jdbc.Driver",
        :PostgreSQL => "org.postgresql.Driver",
      }

      DataMapper::Model.append_inclusions Hibernate::Model

      def initialize(name, options = {})
        @logger = org.slf4j.LoggerFactory.getLogger(HibernateAdapter.to_s.gsub(/::/, '.'))
        dialect = options.delete(:dialect)
        username = options.delete(:username)
        password = options.delete(:password)
        url = options.delete(:url)
        url += "jdbc:" unless url =~ /^jdbc:/
        driver = options.delete(:driver) || DRIVERS[dialect.to_sym]
        pool_size = options.delete(:pool_size) || "1"
        super
        Hibernate.dialect = Hibernate::Dialects.const_get(dialect.to_s)
        Hibernate.current_session_context_class = "thread"
        
        Hibernate.connection_driver_class = driver.to_s
        Hibernate.connection_url = url.to_s # "jdbc:h2:jibernate"
        Hibernate.connection_username = username.to_s # "sa"
        Hibernate.connection_password = password.to_s # ""
        Hibernate.connection_pool_size = pool_size.to_s
        Hibernate.properties["hbm2ddl.auto"] = "update"
        Hibernate.properties["format_sql"] = "false"
        Hibernate.properties["show_sql"] = "false"
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
        @logger.debug("create #{resources.inspect}")
        count = 0
        Hibernate.tx do |session|
          resources.each do |resource|
            session.save(resource)
            count += 1
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
        Hibernate.tx do |session|
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
        model = query.model
        limit = query.limit
        offset = query.offset
        order = query.order

        result = []

        Hibernate.tx do |session|

          # select * from model
          criteria = session.create_criteria(model.java_class)
          # where ...
          criteria.add(parse_conditions_tree(conditions,model))  unless conditions.nil?
          # limit ...
          criteria.set_max_results(limit) unless limit.nil?
          # offset
          criteria.set_first_result(offset) unless offset.nil?
          # order by
          order.each do |direction|
            operator = direction.operator
            # TODO column name may differ from property name
            column = direction.target.name

            if operator == :desc
              criteria.add_order(Order.desc(column.to_s.to_java_string))
            else
              criteria.add_order(Order.asc(column.to_s.to_java_string))
            end
          end

          @logger.debug(criteria.to_s)

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
        resources.each do |resource|
          @logger.debug("deleting #{resource.inspect}")
          Hibernate.tx do |session|
            session.delete(resource)
          end
        end
        resources.size
      end


      private

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

        subject = con.subject.name.to_s # property/column name
        value = con.value # value used in comparison
        model_type = Hibernate::Model::TYPES[model.properties[subject.to_sym].type] # Java type of property (used in typecasting)
        dialect = Hibernate.dialect # SQL dialect for current configuration

        case con
          when DataMapper::Query::Conditions::EqualToComparison
            # special case handling IS NULL/ NOT (x IS NULL)
            value.class == NilClass ? Restrictions.isNull(subject) :
                                      Restrictions.eq(subject, cast_to_hibernate(con.value, model_type))

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
            # special case handling :x => 1..110 / :x => [1,2,3]
            if value.class == Array
              Restrictions.in(subject, cast_to_hibernate(value, model_type))
            else
              # XXX proper ordering?
              arr = value.to_a
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
            # TODO implement custom matching function (see README)
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
            # TODO REFACTOR IT :)
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
            # XXX NullOperation is not used in dm-core at the moment
            raise NotImplementedError, "#{con.class} is not not used in dm-core"
        end
      end

      def parse_conditions_tree (conditions, model)
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
@logger.debug <<EOT
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
@logger.debug <<EOT
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
