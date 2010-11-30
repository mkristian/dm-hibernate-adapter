require 'spec_helper'

require 'dm-core/spec/shared/adapter_spec'

require 'dm-transactions'
require 'dm-migrations'
require 'dm-hibernate-adapter/spec/setup'

ENV['ADAPTER'] = 'hibernate'
ENV['ADAPTER_SUPPORTS'] = 'all'

describe 'DataMapper::Adapters::HibernateAdapter' do

  before :all do
    @adapter = DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate")

    @repository = DataMapper.repository(@adapter.name)
  end

  it_should_behave_like "An Adapter"
end
