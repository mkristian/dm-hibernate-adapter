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

require 'java'
require 'jruby/core_ext'

require 'stringio'

require 'slf4r'
require 'slf4r/java_logger'

require 'dm-core'
require 'dm-transactions'
require 'dm-migrations'

begin
  require 'dm-hibernate-adapter_ext.jar'
rescue LoadError
  warn "missing extension jar, may be it is already in the parent classloader"
end

java_import 'dm_hibernate_adapter.JRubyClassLoader'
java_import 'org.hibernate.criterion.Restrictions'
java_import 'org.hibernate.criterion.Order'
java_import 'java.sql.Connection'
java_import 'java.sql.SQLException'
java_import 'java.sql.Statement'
java_import 'org.hibernate.cfg.AnnotationConfiguration'
java_import 'org.hibernate.tool.hbm2ddl.SchemaExport'
java_import 'org.hibernate.tool.hbm2ddl.SchemaUpdate'

require 'dm-hibernate-adapter/utils/constants'
require 'dm-hibernate-adapter/utils/logger'
require 'dm-hibernate-adapter/hibernate/hibernate'
require 'dm-hibernate-adapter/hibernate/property_shim'
require 'dm-hibernate-adapter/hibernate/dialects'
require 'dm-hibernate-adapter/hibernate/transaction'
require 'dm-hibernate-adapter/hibernate/model'
require 'dm-hibernate-adapter/data_mapper/adapters/hibernate_adapter'

