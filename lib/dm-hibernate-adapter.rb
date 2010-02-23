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

      DataMapper::Model.append_inclusions Hibernate::Model

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
        # puts "create #{resources.inspect}" # XXX logger
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
        # log_update(attributes, collection) # XXX logger
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
        # log_read(query) # XXX logger
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

          # puts criteria.to_s # XXX logger

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
          # puts "deleting #{resource.inspect}" #XXX logger
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
          when Array    then (value.map{|object| cast_to_hibernate(object, model_type)}).to_java
          when Range    then(value.to_a.map{|object| cast_to_hibernate(object, model_type)}).to_java
          when NilClass then "null".to_java_string # TODO is it ok?
          when Regexp   then value.source.to_java_string
          else
            puts "---other Ruby type, object: #{value} type: #{value.class} ---"
            value.to_s.to_java_string
        end
      end

      def handle_comparison(con, model)
        subject = con.subject.name.to_s #property/column name
        # Java type of property (used in typecasting)
        model_type = Hibernate::Model::TYPES[model.properties[subject.to_sym].type]
        # value = convert_ruby_to_java(con.value,model_type)

        case con
          when DataMapper::Query::Conditions::EqualToComparison
            # special case handling IS NULL/ NOT (x IS NULL)
            if con.value.class == NilClass
              Restrictions.isNull(subject)
            else
              Restrictions.eq(subject, cast_to_hibernate(con.value, model_type))
            end
          when DataMapper::Query::Conditions::GreaterThanComparison
            Restrictions.gt(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::LessThanComparison
            Restrictions.lt(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::LikeComparison
            Restrictions.like(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::GreaterThanOrEqualToComparison
            Restrictions.ge(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::LessThanOrEqualToComparison
            Restrictions.le(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::InclusionComparison
            Restrictions.in(subject, cast_to_hibernate(con.value, model_type))
          when DataMapper::Query::Conditions::RegexpComparison
            # TODO is it ok for all dbs (regexp operator) ?
            Restrictions.sqlRestriction(subject +" regexp ?",
                         cast_to_hibernate(con.value, model_type), org::hibernate::Hibernate::STRING)
          else
            # TODO remove that - this case should never be reached
            puts "-----------other comparison: #{con.to_s}--------"
        end
      end

      def parse_all_children(children, model, operand)
        children.each do |child|
          operand.add(parse_conditions_tree(child, model))
        end
        operand
      end

      def parse_the_only_child(child,model)
        parse_conditions_tree(child, model)
      end

      def handle_operation(con, model)
        children = con.children

        case con
          when DataMapper::Query::Conditions::AndOperation
            operand = Restrictions.conjunction()
            return parse_all_children(children, model, operand)
          when DataMapper::Query::Conditions::OrOperation
            operand = Restrictions.disjunction()
            return parse_all_children(children, model, operand)
          when DataMapper::Query::Conditions::NotOperation
            #TODO only one child may be negated in DM?
            child = children.first
            return  Restrictions.not(parse_the_only_child(child,model))
          # when DataMapper::Query::Conditions::NullOperation
          # XXX NullOperation is not used in dm-core at the moment

          else
            # TODO remove that - this case should never be reached
            puts "-----------other operand: #{con.to_s}--------"
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

# @param [Hash(Property => Object)] attributes
#   hash of attribute values to print it out formatted, keyed by Property
# @param [Collection] collection
#   collection of records to print it out formatted
#
# @api private
def log_update(attributes,collection)
puts <<EOT
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
