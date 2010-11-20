require 'dm-hibernate-adapter'
require 'dm-core/spec/setup'

module DataMapper
  module Spec
    module Adapters

      class HibernateAdapter < AbstractAdapter
      end

      use HibernateAdapter

    end
  end
end