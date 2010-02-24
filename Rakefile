require 'rake'

SPEC_LOCATIONS = { :abstract_adapter => "spec/abstract_adapter", :dm_core => "spec/dm_core" }

def with_gem(gemname, &blk)
  begin
    require gemname
    blk.call
  rescue LoadError => e
    puts "Failed to load gem #{gemname} because #{e}."
  end
end

with_gem 'spec/rake/spectask' do

  namespace :spec do
    desc 'Run AbstractAdapter specs'
    Spec::Rake::SpecTask.new(:adapter) do |t|
      if File.exists?("#{SPEC_LOCATIONS[:abstract_adapter]}/spec.opts")
        t.spec_opts << '--options' << "#{SPEC_LOCATIONS[:abstract_adapter]}/spec.opts"
      end
      t.libs << 'lib'
      t.spec_files = FileList["#{SPEC_LOCATIONS[:abstract_adapter]}/**_spec.rb"]
    end

    desc 'Run dm_core specs'
    Spec::Rake::SpecTask.new(:dm) do |t|
      if File.exists?("#{SPEC_LOCATIONS[:dm_core]}/spec.opts")
        t.spec_opts << '--options' << "#{SPEC_LOCATIONS[:dm_core]}/spec.opts"
      end
      t.libs << 'lib'
      t.spec_files = FileList["#{SPEC_LOCATIONS[:dm_core]}/**/**_spec.rb"]
    end
  end

end

with_gem 'yard' do
  desc "Generate Yardoc"
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'README.markdown']
  end
end


