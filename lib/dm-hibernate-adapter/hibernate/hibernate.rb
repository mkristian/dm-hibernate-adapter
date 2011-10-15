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

module Hibernate

  @@mapped_classes = {}
  @@logger         = Slf4r::LoggerFacade.new(Hibernate)

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

  def self.allow_reload=(allow)
    @allow = allow
  end

  def self.allow_reload
    @allow || false
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

  def self.add_model(model_java_class, model)
    unless mapped? model
      config.add_annotated_class model_java_class
      @@mapped_classes[model.name] = model.hash
      @@logger.debug " model/class #{model_java_class} registered successfully"
    else
      @@logger.debug " model/class #{model_java_class} registered already"
    end
  end

  private

    def self.mapped?(model)
      if @@mapped_classes[model.name] && @@mapped_classes[model.name] != model.hash && self.allow_reload
        reset_config
      end
      @@mapped_classes[model.name] == model.hash
    end

end

