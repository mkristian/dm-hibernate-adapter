module Hibernate
  # XXX java_import: http://jira.codehaus.org/browse/JRUBY-3538
  java_import org.hibernate.cfg.AnnotationConfiguration
  JClass = java.lang.Class
  JVoid = java.lang.Void::TYPE

  def self.dialect=(dialect)
    config.set_property "hibernate.dialect", dialect
  end

  def self.current_session_context_class=(ctx_cls)
    config.set_property "hibernate.current_session_context_class", ctx_cls
  end

  def self.connection_driver_class=(driver_class)
    config.set_property "hibernate.connection.driver_class", driver_class
  end

  def self.connection_url=(url)
    config.set_property "hibernate.connection.url", url
  end

  def self.connection_username=(username)
    config.set_property "hibernate.connection.username", username
  end

  def self.connection_password=(password)
    config.set_property "hibernate.connection.password", password
  end

  def self.connection_pool_size=(size)
    config.set_property "hibernate.connection.pool_size", size
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
    PropertyShim.new(@config)
  end

  def self.tx
    session.begin_transaction
    if block_given?
      yield session
      session.transaction.commit
    end
  end

  def self.factory
    @factory ||= config.build_session_factory
  end

  def self.session
    factory.current_session
  end

  def self.config
    @config ||= AnnotationConfiguration.new
  end

  def self.add_model(model_java_class)
    #TODO workaround
    unless mapped?(model_java_class)
      config.add_annotated_class(model_java_class)
      @mapped_classes << model_java_class
    else
      puts "model/class #{model_java_class} registered already"
    end
  end

  private

  def self.mapped?(clazz)
    @mapped_classes ||= []
    if @mapped_classes.member?(clazz)
      return true
    else
      return false
    end
  end

  module Model

    # TODO enhance TYPEs list
    TYPES = {
      ::String => java.lang.String,
      ::Integer => java.lang.Integer,
      ::Date => java.util.Date,
      ::DataMapper::Types::Boolean => java.lang.Boolean,
      ::DataMapper::Types::Serial => java.lang.Long
    }

    def self.included(model)
      model.extend(ClassMethods)
    end

    module ClassMethods

      def auto_migrate!
        #TODO add support for auto_migrate!
        puts "---- auto_migrate! invoked! ----"
      end

      private

      def hibernate_sigs
        @hibernate_sigs ||= {}
      end

      # "stolen" from http://github.com/superchris/hibernate
      def add_java_property(name, type, annotation = nil)
        get_name = "get#{name.to_s.capitalize}"
        set_name = "set#{name.to_s.capitalize}"

        # TODO DateTime and Time
        if(type == ::Date)
          class_eval <<-EOT
 def _#{name}=(d)
   attribute_set(:#{name}, Date.civil(d.year + 1900, d.month + 1, d.date))
 end

 def _#{name}
   d = attribute_get(:#{name})
   org.joda.time.DateTime.new(d.year, d.month, d.day, 0, 0, 0, 0).to_date
 end
          EOT
          name = :"_#{name}"
        end
        alias_method get_name.intern, name
        add_method_signature get_name, [TYPES[type].java_class]
        add_method_annotation get_name, annotation if annotation
        alias_method set_name.intern, :"#{name.to_s}="
        add_method_signature set_name, [JVoid, TYPES[type].java_class]
      end

      def hibernate_attr(attrs)
        attrs.each do |name, type|
          add_java_property(name, type)
        end
      end

      # "stolen" from http://github.com/superchris/hibernate
      def hibernate_identifier(name, type)
        add_java_property(name, type, javax.persistence.Id => {}, javax.persistence.GeneratedValue => {})
      end

      def hibernate!
        #TODO workaround
        unless mapped?
          properties.each do |prop|
            # TODO honor prop.field mapping and maybe more
            if prop.serial?
              hibernate_identifier(prop.name, prop.type)
            else
              add_java_property(prop.name, prop.type)
            end
          end

          # "stolen" from http://github.com/superchris/hibernate
          # TODO honor self.storage_name as table
          add_class_annotation(javax.persistence.Entity => {})
          java_class = become_java!
          Hibernate.add_model(java_class)
          @mapped_class = true
        else
          puts "model fired become_java! already"
        end

        # Hibernate.mappings.
        # Hibernate.add_mapping reified_class,
      end

      #helper method
      def mapped?
        !instance_variable_get('@mapped_class').nil?
      end

    end
  end
end
