require 'spec_helper'

require 'dm-core/spec/shared/adapter_spec'

describe 'DataMapper::Adapters::HibernateAdapter' do
  before :all do
    @adapter = DataMapper::Spec.adapter
    @repository = DataMapper.repository(@adapter.name)    
  end  

  it_should_behave_like "An Adapter"
end
