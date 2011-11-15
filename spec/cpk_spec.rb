require 'spec_helper'

dm_core_spec_path = $:.select {|path| path =~ /dm-core/ }.first.gsub(/lib$/, 'spec')

# load from dm-core specs still not working
# spec_helper not work with multiples specs
# cpk implementation are broken in 'should be able to access the child'
# require "#{dm_core_spec_path}/public/associations/many_to_one_with_boolean_cpk_spec"
