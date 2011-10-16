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

require 'rubygems'
require 'lib/dm-hibernate-adapter'

require 'dm-core/spec/lib/pending_helpers'
require 'dm-core/spec/lib/adapter_helpers'
require 'dm-core/spec/lib/collection_helpers'

# https://github.com/datamapper/dm-core/tree/master/lib/dm-core/spec
require 'dm-core/spec/shared/adapter_spec'


DB_CONFIGS = {
  :H2_EMB     => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate" },
  :DERBY_EMB  => { :adapter => "hibernate", :dialect => "Derby", :url => "jdbc:derby:target/jibernate;create=true" },
  :HSQL_EMB   => { :adapter => "hibernate", :dialect => "HSQL", :username => "sa", :url => "jdbc:hsqldb:file:target/testdb;create=true" },
  :MySQL5     => { :adapter => "hibernate", :dialect => "MySQL5", :username => "root", :password => "root",
                   :url => "jdbc:mysql://localhost:3306/jibernate"},
  :PostgreSQL => { :adapter => "hibernate", :dialect => "PostgreSQL", :username => "postgres", :password => "postgres",
                   :url => "jdbc:postgresql://localhost:5432/jibernate"}
}

Spec::Runner.configure do |config|
  config.include DataMapper::Spec::PendingHelpers
  # config.include DataMapper::Spec::AdaptersHelpers
  # config.include DataMapper::Spec::CollectionHelpers

  config.before :all do
    @adapter = DataMapper.setup(:default, DB_CONFIGS[(ENV['DIALECT'] || :H2_EMB).to_sym])
  end

end

