require File.dirname(__FILE__) + '/spec_helper'

# TODO should be:
#require 'dm-core/spec/adapter_shared_spec'
# TODO but for now there is modified AbstractAdapter spec:
require 'adapter_shared_spec'
require 'hibernate_shared_spec'

describe DataMapper::Adapters::HibernateAdapter do
  before :all do
    @adapter = DataMapper.setup(:default, :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:jibernate" )
  end

  it_should_behave_like 'An Adapter'

  # TODO add hibernate specyfic specs
  it_should_behave_like 'An Hibernate Adapter'

end
