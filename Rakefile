require 'rake'

SPEC_LOCATIONS = {
  :abstract_adapter => "spec/abstract_adapter",
  :dm_core          => "spec",
  :transient        => "spec/transient"
}

def with_gem(gemname, &blk)
  begin
    require gemname
    blk.call
  rescue LoadError => e
    puts "Failed to load gem #{gemname} because #{e}."
  end
end

with_gem 'spec/rake/spectask' do

  desc 'Run specs'
  Spec::Rake::SpecTask.new(:spec) do |t|
    if File.exists?("#{SPEC_LOCATIONS[:dm_core]}/spec.opts")
      t.spec_opts << '--options' << "#{SPEC_LOCATIONS[:dm_core]}/spec.opts"
    end
    t.libs << 'lib'
    t.spec_files = FileList["#{SPEC_LOCATIONS[:dm_core]}/**/**_spec.rb"]
  end

end

with_gem 'yard' do
  desc "Generate Yardoc"
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'README.markdown']
  end
end


