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

module Hibernate::DynamicJava

  def make_java_class(annotations = {})
    add_class_annotation annotations if !annotations.empty?

    reload = Hibernate.allow_reload
    become_java!(reload)

    if reload
      unless java.lang.Thread.currentThread.context_class_loader.is_a? JRubyClassLoader
        cl = java.lang.Thread.currentThread.context_class_loader
        if cl.is_a? org.jruby.util.JRubyClassLoader
          java.lang.Thread.currentThread.context_class_loader = JRubyClassLoader.new(cl)
        else
          java.lang.Thread.currentThread.context_class_loader = 'TODO'
        end
      end

      java.lang.Thread.currentThread.context_class_loader.register(self.java_class)
    end
    self
  end
  
  def add_get_accessor(name, target_type, annotations = {}, &blk)
    get_name = "get#{name.to_s.capitalize}"
    define_method(get_name.to_sym, &blk)
    mapped_type = to_java_type(target_type).java_class
    add_method_signature get_name, [mapped_type]
    add_method_annotation get_name, annotations if !annotations.empty?
  end  

  def add_set_accessor(name, target_type, annotations = {}, &blk)
    set_name = "set#{name.to_s.capitalize}"
    define_method(set_name.to_sym, &blk)
    mapped_type = to_java_type(target_type).java_class
    add_method_signature set_name, [JVoid, mapped_type]
    add_method_annotation set_name, annotations if !annotations.empty?
  end  
  
  def to_java_type(target_type)
    target_type = target_type.primitive if target_type.respond_to?(:primitive)
    TYPES[target_type] || target_type
  end
end
