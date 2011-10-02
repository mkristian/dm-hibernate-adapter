module Hibernate

  @@mapped_classes = {}

  # java_import: http://jira.codehaus.org/browse/JRUBY-3538
  java_import org.hibernate.cfg.AnnotationConfiguration
  JClass  = java.lang.Class
  JVoid   = java.lang.Void::TYPE

  @@logger = Slf4r::LoggerFacade.new(Hibernate)

  def self.dialect=(dialect)
    config.set_property "hibernate.dialect", dialect
  end

  def self.dialect
    config.get_property "hibernate.dialect"
  end

  def self.current_session_context_class=(ctx_cls)
    config.set_property "hibernate.current_session_context_class", ctx_cls
  end

  def self.connection_driver_class=(driver_class)
    config.set_property "hibernate.connection.driver_class", driver_class
  end

  def self.connection_driver_class
    config.get_property "hibernate.connection.driver_class"
  end

  def self.connection_url=(url)
    config.set_property "hibernate.connection.url", url
  end

  def self.connection_url
    config.get_property "hibernate.connection.url"
  end

  def self.connection_username=(username)
    config.set_property "hibernate.connection.username", username
  end

  def self.connection_username
    config.get_property "hibernate.connection.username"
  end

  def self.connection_password=(password)
    config.set_property "hibernate.connection.password", password
  end

  def self.connection_password
    config.get_property "hibernate.connection.password"
  end

  def self.connection_pool_size=(size)
    config.set_property "hibernate.connection.pool_size", size
  end

  def self.connection_pool_size
    config.get_property "hibernate.connection.pool_size"
  end

  class PropertyShim

    def initialize(config)
      @config = config
    end

    def []=(key, value)
      key = ensure_hibernate_key(key)
      @config.set_property key, value
    end

    def [](key)
      key = ensure_hibernate_key(key)
      config.get_property key
    end

    private

      def ensure_hibernate_key(key)
        unless key =~ /^hibernate\./
          key = 'hibernate.' + key
        end
        key
      end
  end

  def self.properties
    @@property_shim ||= PropertyShim.new(@@config)
  end

  def self.tx(&block)
    # http://community.jboss.org/wiki/sessionsandtransactions
    if block_given?
      s = nil
      begin
        s = session
        s.begin_transaction
        block.call s
        s.transaction.commit
      rescue => e
        s.transaction.rollback if s
        raise e
      ensure
        s.close if s
      end
    else
      raise "not supported"
    end
  end

  def self.factory
    @@factory ||= config.build_session_factory
  end

  def self.session
    factory.open_session
  end

  def self.reset_config
    if @@config
      # TODO make the whole with a list of property names
      # define the static accessors with the very same list
      dialect = self.dialect
      username = self.connection_username
      password = self.connection_password
      url = self.connection_url
      driver_class = self.connection_driver_class
      @@factory = nil
      @@config = AnnotationConfiguration.new
      self.dialect= dialect
      self.connection_username = username
      self.connection_password = password
      self.connection_url = url
      self.connection_driver_class = driver_class
    end
  end

  def self.config
    @@config ||= AnnotationConfiguration.new
  end

  def self.add_model(model_java_class, name)
    unless mapped? name
      config.add_annotated_class model_java_class
      @@mapped_classes[name] = true
      @@logger.debug " model/class #{model_java_class} registered successfully"
    else
      @@logger.debug " model/class #{model_java_class} registered already"
    end
  end

  private

    def self.mapped?(name)
      @@mapped_classes[name]
    end

  module Model

    TYPES = {
      ::String                         => java.lang.String,
      ::Integer                        => java.lang.Integer,
      ::Float                          => java.lang.Double,
      ::BigDecimal                     => java.math.BigDecimal,
      ::Date                           => java.util.Date,
      ::DateTime                       => java.util.Date,
      ::Time                           => java.util.Date,
      ::TrueClass                      => java.lang.Boolean,
    }

    def self.included(model)

      model.extend(ClassMethods)

#       this part is needed for the model A.create method to work
#       model.class_eval <<-EOF
#          alias :initialize_old :initialize
#          def initialize(*args)
#             if self.class.hibernate!
#               self.class.new(*args)
#             else
#               initialize_old(*args)
#             end
#          end
# EOF

      unless model.mapped?
        [:auto_migrate!, :auto_upgrade!, :create, :all, :copy, :first, :first_or_create, :first_or_new, :get, :last, :load].each do |method|
          model.before_class_method(method, :hibernate!)
        end

        [:save, :update, :destroy, :update_attributes].each do |method|
          model.before(method) { model.hibernate! }
        end
      end

    end

    module ClassMethods

      java_import org.hibernate.tool.hbm2ddl.SchemaExport
      java_import org.hibernate.tool.hbm2ddl.SchemaUpdate

      @@logger = Slf4r::LoggerFacade.new(Hibernate::Model)

      def auto_migrate!(repo = nil)
        config = Hibernate::config

        schema_export = SchemaExport.new(config)
        # here you can turn on/off logger
        console       = true
        schema_export.drop(console,true)
        schema_export.create(console,true)
      end

      def auto_upgrade!(repo = nil)
      end

      def to_java_type(type)
        TYPES[type] || self.to_java_type(type.primitive)
      end


      def to_java_class_name
        # http://jira.codehaus.org/browse/JRUBY-4601
        "rubyobj."+self.to_s.gsub("::",".")
      end

      def hibernate!
        result = false
        relationships.each do |property, relationship|
          next unless relationship

          relationship.child_key
          relationship.parent_key
          relationship.through    if relationship.respond_to?(:through)
          relationship.via        if relationship.respond_to?(:via)
        end

        unless mapped?
          discriminator = nil

          # relationships.each do |rel|
          # end

          properties.each do |prop|
            discriminator = add_java_property(prop) || discriminator
          end

          # "stolen" from http://github.com/superchris/hibernate
          annotation = {
            javax.persistence.Entity => { },
            javax.persistence.Table  => { "name" => self.storage_name }
          }

          if discriminator
            annotation[javax.persistence.Inheritance]         = { "strategy" => javax.persistence.InheritanceType::SINGLE_TABLE.to_s }
            annotation[javax.persistence.DiscriminatorColumn] = { "name" => discriminator }
          end

          add_class_annotation annotation
          Hibernate.add_model become_java!(false), name
          result = true

          @@logger.debug "become_java! #{java_class}"
        else
          @@logger.debug "become_java! fired already #{java_class}"
        end
        result
      end

      def mapped?
        Hibernate.mapped? name
      end

      private

        # "stolen" from http://github.com/superchris/hibernate
        def add_java_property(prop)
          @@logger.info("#{prop.model.name} gets property added #{prop.name}")
          name = prop.name
          type = prop.class
          return name if (type == DataMapper::Property::Discriminator)

          column_name = prop.field
          annotation = {}

          if prop.serial?
            annotation[javax.persistence.Id] = {}
            annotation[javax.persistence.GeneratedValue] = {}
          elsif prop.key?
            annotation[javax.persistence.Id] = {}
          end

          annotation[javax.persistence.Column] = {
            "unique" => prop.unique?,
            "name"   => prop.field
          }

          unless prop.index.nil?
            if (prop.index == true)
              annotation[org.hibernate.annotations.Index]
            elsif (prop.index.class == Symbol)
              annotation[org.hibernate.annotations.Index] = {"name" => prop.index.to_s}
            else
              # TODO arrays !!
              #annotation[org.hibernate.annotations.Index] = {"name" => []}
              #prop.index.each do|index|
              #  annotation[org.hibernate.annotations.Index]["name"] << index.to_s
              #end
            end
          end
          if prop.required?
            annotation[javax.persistence.Column]["nullable"] = !prop.required?
          end
          if (prop.respond_to?(:length) && !prop.length.nil?)
            annotation[javax.persistence.Column]["length"] = java.lang.Integer.new(prop.length)
          end
          if (prop.respond_to?(:scale) && !prop.scale.nil?)
            annotation[javax.persistence.Column]["scale"] = java.lang.Integer.new(prop.scale)
          end
          if (prop.respond_to?(:precision) && !prop.precision.nil?)
            annotation[javax.persistence.Column]["precision"] = java.lang.Integer.new(prop.precision)
          end

          get_name = "get#{name.to_s.capitalize}"
          set_name = "set#{name.to_s.capitalize}"

          # TODO Time, Discriminator, EmbededValue
          # to consider: in my opinion those methods should set from/get to java objects...
          if (type == DataMapper::Property::Date)
            class_eval <<-EOT
              def  #{set_name.intern} (d)
                attribute_set(:#{name} , d.nil? ? nil : Date.civil(d.year + 1900, d.month + 1, d.date))
              end
            EOT
            class_eval <<-EOT
              def  #{get_name.intern}
                d = attribute_get(:#{name} )
                org.joda.time.DateTime.new(d.year, d.month, d.day, 0, 0, 0, 0).to_date if d
              end
            EOT
          elsif (type == DataMapper::Property::DateTime)
            class_eval <<-EOT
              def  #{set_name.intern} (d)
                attribute_set(:#{name} , d.nil? ? nil : DateTime.civil(d.year + 1900, d.month + 1, d.date, d.hours, d.minutes, d.seconds))
              end
            EOT
            class_eval <<-EOT
              def  #{get_name.intern}
                d = attribute_get(:#{name} )
                org.joda.time.DateTime.new(d.year, d.month, d.day, d.hour, d.min, d.sec, 0).to_date if d
              end
            EOT
          elsif (type.to_s == BigDecimal || type == DataMapper::Property::Decimal)
            class_eval <<-EOT
              def  #{set_name.intern} (d)
                attribute_set(:#{name} , d.nil? ? nil :#{type}.new(d.to_s))
              end
            EOT
            class_eval <<-EOT
              def  #{get_name.intern}
                d = attribute_get(:#{name} )
                java.math.BigDecimal.new(d.to_i) if d
              end
            EOT
          else
            class_eval <<-EOT
              def  #{set_name.intern} (d)
                attribute_set(:#{name} , d)
              end
            EOT
            class_eval <<-EOT
              def  #{get_name.intern}
                d = attribute_get(:#{name} )
                d
              end
            EOT
          end

          mapped_type = to_java_type(type).java_class
          add_method_signature get_name, [mapped_type]
          add_method_annotation get_name, annotation
          add_method_signature set_name, [JVoid, mapped_type]
          nil
        end
    end
  end
end
