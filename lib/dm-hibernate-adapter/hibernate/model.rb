# -*- coding: utf-8 -*-
# Copyright 2011 Douglas Ferreira, Kristian Meier, Piotr Gęga

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Hibernate::Model
  def self.included(model)
    model.extend(ClassMethods)
    model.extend(Hibernate::DynamicJava)
    model.extend(PropertyTransformer)
  end

  module ClassMethods

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

    def to_java_class_name
      # http://jira.codehaus.org/browse/JRUBY-4601
      "rubyobj."+self.to_s.gsub("::",".")
    end

    def hibernate!
      unless Hibernate.mapped?(self)
        discriminator = nil

        relationships.each do |relationship|
          relationship.source_key
          relationship.target_key
        end

        filtered_properties = multi_keys? ? properties.reject {|prop| prop.key?} : properties
        filtered_properties.each do |prop|
          discriminator = add_java_property(prop) || discriminator
        end

        add_composite_key_property if multi_keys?

        # "stolen" from http://github.com/superchris/hibernate
        annotation = {
          javax.persistence.Entity => { },
          javax.persistence.Table  => { "name" => self.storage_name }
        }

        if discriminator
          annotation[javax.persistence.Inheritance]         = { "strategy" => javax.persistence.InheritanceType::SINGLE_TABLE.to_s }
          annotation[javax.persistence.DiscriminatorColumn] = { "name" => discriminator }
        end

        Hibernate.add_model(make_java_class(annotation), self)

        @@logger.debug "become_java! #{java_class}"
      else
        @@logger.debug "become_java! fired already #{java_class}"
      end
    end

    def multi_keys?
      key.size > 1
    end

    def add_composite_key_property
      add_get_accessor(:composite_key, composite_class, javax.persistence.EmbeddedId => {}) do
        # if !instance_variable_defined?(:@composite_key) || @composite_key.nil?
        #   any_instance_key_defined = !key.map {|prop| attribute_get(prop.name) }.reject {|elem| elem.nil? }.empty
        #   @composite_key = any_instance_key_defined ? composite_class.new : nil
        # end
        # @composite_key
        @composite_key = @@composite_class.new
        @composite_key.owner = self

        @composite_key
      end

      add_set_accessor(:composite_key, composite_class) do |value|
        @composite_key = value
        @composite_key.owner = self
      end
    end

    def composite_class
      @@composite_class ||= make_composite_class
    end  
    
    def make_composite_class
      model = self
      Class.new do
        include java.io.Serializable
        extend Hibernate::DynamicJava
        extend PropertyTransformer

        attr_accessor :owner
        
        model.key.each do |prop_key|
          self.add_java_property(prop_key, :simple_key? => false)
        end
        self.make_java_class(javax.persistence.Embeddable => {})        
      end
    end      
  end
  module PropertyTransformer
    @@logger = Slf4r::LoggerFacade.new(Hibernate::Model)

    def add_java_property(prop, options = {:simple_key? => true})
      @@logger.info("#{prop.model.name} gets property added #{prop.name}")
      name = prop.name
      property_type = prop.class
      return name if (property_type == DataMapper::Property::Discriminator)

      make_accessors(name, property_type, build_annotation(prop, options))
      nil
    end

    def build_annotation(prop, options)
      annotation = {}

      if options[:simple_key?]
        if prop.serial?
          annotation[javax.persistence.Id] = {}
          annotation[javax.persistence.GeneratedValue] = {}
        elsif prop.key? 
          annotation[javax.persistence.Id] = {}
        end
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
      annotation
    end

    def make_accessors(name, property_type, accessor_annotations = {})
       get_accessor_block = AccessorStrategy.get_accessor_block(name, property_type)
       add_get_accessor(name, property_type, accessor_annotations, &get_accessor_block)

       set_accessor_block = AccessorStrategy.set_accessor_block(name, property_type)
       add_set_accessor(name, property_type, accessor_annotations, &set_accessor_block)
    end  
  end

  module AccessorStrategy
    
    STRATEGY = {
      ::Date => {
        :set => Proc.new {|d| Date.civil(d.year + 1900, d.month + 1, d.date) },
        :get => Proc.new {|d|  org.joda.time.DateTime.new(d.year, d.month, d.day, 0, 0, 0, 0).to_date }
      },
      ::DateTime => {
        :set => Proc.new {|d| DateTime.civil(d.year + 1900, d.month + 1, d.date, d.hours, d.minutes, d.seconds) },
        :get => Proc.new {|d| org.joda.time.DateTime.new(d.year, d.month, d.day, d.hour, d.min, d.sec, 0).to_date }
      },

      ::BigDecimal => {
        :set => Proc.new {|d| BigDecimal.new(d.to_s) },
        :get => Proc.new {|d| java.math.BigDecimal.new(d.to_s) }
      },
    }

    def self.get_accessor_block(property_name, property_type)
      Proc.new do
        owner_instance = self.respond_to?(:owner) ? self.owner : self
        AccessorStrategy.strategy_of(:get, property_name, property_type, owner_instance.attribute_get(property_name.to_sym))
      end  
    end  

    def self.set_accessor_block(property_name, property_type)
      Proc.new do |value|
        owner_instance = self.respond_to?(:owner) ? self.owner : self
        owner_instance.attribute_set(property_name.to_sym, AccessorStrategy.strategy_of(:set, property_name, property_type, value))
      end  
    end  

    def self.strategy_of(strategy_type, property_name, property_type, value)
      value = STRATEGY[property_type][strategy_type].call(value) if !STRATEGY[property_type].nil? && !value.nil?
      value
    end  
  end  
end
