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

require 'dm-hibernate-adapter'
require 'dm-core/spec/setup'

module DataMapper
  module Spec
    module Adapters

      class HibernateAdapter < Adapter

        def setup!
          #adapter = DataMapper.setup(name, connection_uri)
          adapter = DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate")

          test_connection(adapter)
          adapter
        rescue Exception => e
          puts "Could not connect to the database using '#{connection_uri}' because of: #{e.inspect}"
        end

      end

      use HibernateAdapter
    end
  end
end
