require 'pathname'
require 'rubygems'

require 'addressable/uri'
require 'spec'

org.apache.log4j.PropertyConfigurator.configure(File.dirname(__FILE__) + '/log4j.properties')

require 'dm-hibernate-adapter'

SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
$LOAD_PATH.unshift(SPEC_ROOT.parent + 'lib')

ENV['PLUGINS'].to_s.strip.split(/\s+/).each do |plugin|
  require plugin
end

Pathname.glob((SPEC_ROOT + '{lib,*/shared}/**/*.rb').to_s).each { |file| require file }

# create sqlite3_fs directory if it doesn't exist
temp_db_dir = SPEC_ROOT.join('db')
temp_db_dir.mkpath

#ENV['ADAPTERS'] ||= 'all'

HAS_DO = DataMapper::Adapters.const_defined?('DataObjectsAdapter')

ADAPTERS = []

PRIMARY = {
  'default'    => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:jibernate" },
  # 'in_memory'  => { :adapter => :in_memory },
}

ALTERNATE = {
  'default'    => { :adapter => "hibernate", :dialect => "H2", :username => "sa", :url => "jdbc:h2:jibernate" },
  # 'in_memory'  => { :adapter => :in_memory },
}

#adapters = ENV['ADAPTERS'].split(' ').map { |adapter_name| adapter_name.strip.downcase }.uniq
adapters = "default"

#adapters = PRIMARY.keys if adapters.include?('all')

PRIMARY.only(*adapters).each do |name, default|
  connection_string = ENV["#{name.upcase}_SPEC_URI"] || default
  begin
    adapter = DataMapper.setup(name,connection_string)

    # test the connection if possible
    if adapter.respond_to?(:query)
      name == 'oracle' ? adapter.select('SELECT 1 FROM dual') : adapter.select('SELECT 1')
    end

    ADAPTERS << name
    PRIMARY[name] = connection_string  # ensure *_SPEC_URI is saved
   rescue Exception => exception
     puts "Could not connect to the database using #{connection_string.inspect} because: #{exception.inspect}"
  end
end

# speed up test execution on Oracle
if defined?(DataMapper::Adapters::OracleAdapter)
  DataMapper::Adapters::OracleAdapter.instance_eval do
    auto_migrate_with :delete           # table data will be deleted instead of dropping and creating table
    auto_migrate_reset_sequences false  # primary key sequences will not be reset
  end
end

ADAPTERS.freeze
PRIMARY.freeze

logger = DataMapper::Logger.new(DataMapper.root / 'log' / 'dm.log', :debug)
logger.auto_flush = true

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::AdapterHelpers)
  config.include(DataMapper::Spec::PendingHelpers)

  def remove_ivars(object, instance_variables = object.instance_variables)
    seen  = {}
    stack = instance_variables.map { |var| [ object, var ] }

    while node = stack.pop
      object, ivar = node

      # skip "global" and non-DM objects
      next if object.kind_of?(DataMapper::Logger)               ||
              object.kind_of?(DataMapper::Model::DescendantSet) ||
              object.class.name[0, 13] == 'DataObjects::'

      # skip classes and modules in the DataMapper namespace
      next if object.kind_of?(Module) &&
              object.name[0, 12] == 'DataMapper::'

      # skip when the ivar is no longer defined in the object
      next unless object.instance_variable_defined?(ivar)

      value = object.instance_variable_get(ivar)
      object.__send__(:remove_instance_variable, ivar) unless object.frozen?

      # skip when the value was seen
      next if seen.key?(value.object_id)
      seen[value.object_id] = true

      stack.concat value.instance_variables.map { |ivar| [ value, ivar ] }
    end
  end

  config.after :all do
    # global model cleanup
    descendants = DataMapper::Model.descendants.to_a
    while model = descendants.shift
      descendants.concat(model.descendants.to_a - [ model ])

      parts         = model.name.split('::')
      constant_name = parts.pop.to_sym
      base          = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      if constant_name.to_s[0] != ?# && base.const_defined?(constant_name)
        base.send(:remove_const, constant_name)
      end

      remove_ivars(model)
      model.instance_methods(false).each { |method| model.send(:undef_method, method) }

      DataMapper::Model.descendants.delete(model)
    end
  end

  config.after :all do
    # global ivar cleanup
    remove_ivars(self, instance_variables.reject { |ivar| ivar[0, 2] == '@_' })
  end

  config.after :all do
    # WTF: rspec holds a reference to the last match for some reason.
    # When the object ivars are explicitly removed, this causes weird
    # problems when rspec uses it (!).  Why rspec does this I have no
    # idea because I cannot determine the intention from the code.
    remove_ivars(Spec::Matchers.last_matcher, %w[ @expected ])
  end
end

# TODO :send !
## remove the Resource#send method to ensure specs/internals do no rely on it
#module RemoveSend
#  def self.included(model)
#    model.send(:undef_method, :send)
#    model.send(:undef_method, :freeze)
#  end
#
#  DataMapper::Model.append_inclusions self
#end
