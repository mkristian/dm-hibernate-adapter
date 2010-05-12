
dir = Pathname(__FILE__).dirname.expand_path.to_s
dir_shared = dir + "/shared"

require dir + '/spec_helper'

require dir_shared + '/adapter_shared_spec'
require dir_shared + '/model_spec'
require dir_shared + '/finder_shared_spec'
require dir_shared + '/property_spec'
require dir_shared + '/resource_spec'
require dir_shared + '/resource_shared_spec'
require dir_shared + '/sel_shared_spec'

describe DataMapper::Adapters::HibernateAdapter do
  DB_CONFIGS = {
    :H2_EMB     => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:target/jibernate" },
    :DERBY_EMB  => { :adapter => "hibernate", :dialect => "Derby", :url => "jdbc:derby:target/jibernate;create=true" },
    :HSQL_EMB   => { :adapter => "hibernate", :dialect => "HSQL", :username => "sa", :url => "jdbc:hsqldb:file:target/testdb;create=true" },
    :MySQL5     => { :adapter => "hibernate", :dialect => "MySQL5", :username => "root", :password => "root",
                     :url => "jdbc:mysql://localhost:3306/jibernate"},
    :PostgreSQL => { :adapter => "hibernate", :dialect => "PostgreSQL", :username => "postgres", :password => "postgres",
                     :url => "jdbc:postgresql://localhost:5432/jibernate"}
  }.freeze

  # XXX Add drivers to run specs against them
  DRIVERS = [ (ENV['DIALECT'] || :H2_EMB).to_sym ]
  
  # "big ones"
  # DRIVERS = [ :MySQL5, :PostgreSQL ].freeze
  # "small ones"
  # DRIVERS = [ :H2_EMB, :DERBY_EMB, :HSQL_EMB ].freeze
  # all
  # DRIVERS = [ :H2_EMB, :DERBY_EMB, :HSQL_EMB, :MySQL5, :PostgreSQL ].freeze

  # iterate over selected drivers and run specs
  DB_CONFIGS.only(*DRIVERS).each do |driver, connection_options|

    describe "with +#{driver}+ driver => " do

      before :all do
        @adapter = DataMapper.setup(:default, connection_options )
      end

      # Abstract adapter spec
      # it_should_behave_like 'An Adapter' # STATUS: ~OK
      # property_spec.rb
      it_should_behave_like 'An Adapter with property_spec support'

      # model_spec.rb
      # it_should_behave_like 'An Adapter with model_spec support' # STATUS: PENDING
      # resource_spec.rb
      # it_should_behave_like 'An Adapter with resource_spec support' # STATUS: PENDING

    end
  end
end
