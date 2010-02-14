require 'java'
require 'stringio'

require 'dialects'

module Hibernate
  # XXX http://jira.codehaus.org/browse/JRUBY-3538
  java_import org.hibernate.cfg.Configuration
  # XXX not needed for now
  # import javax.xml.parsers.DocumentBuilderFactory
  # import org.xml.sax.InputSource
  # DOCUMENT_BUILDER_FACTORY = DocumentBuilderFactory.new_instance
  # DOCUMENT_BUILDER_FACTORY.validating = false
  # DOCUMENT_BUILDER_FACTORY.expand_entity_references = false
  # DOCUMENT_BUILDER = DOCUMENT_BUILDER_FACTORY.new_document_builder
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
    @config ||= Configuration.new
  end

  def self.add_model(mapping)
    config.add_xml(File.read(mapping))
  end

  module Model
    TYPES = {
      :string => java.lang.String,
      :long => java.lang.Long,
      :date => java.util.Date
    }

    def hibernate_sigs
      @hibernate_sigs ||= {}
    end

    def hibernate_attr(attrs)
      attrs.each do |name, type|
        attr_accessor name
        get_name = "get#{name.to_s.capitalize}"
        set_name = "set#{name.to_s.capitalize}"

        alias_method get_name.intern, name
        add_method_signature get_name, [TYPES[type].java_class]
        alias_method set_name.intern, :"#{name.to_s}="
        add_method_signature set_name, [JVoid, TYPES[type].java_class]
      end
    end
    
    def hibernate!
      become_java!

    # Hibernate.mappings.
    # Hibernate.add_mapping reified_class,
    end
  end
end
