require 'rake'


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
    if File.exists?("spec/spec.opts")
      t.spec_opts << '--options' << "spec/spec.opts"
    end
    t.libs << 'lib'
    t.spec_files = FileList["spec//**/**_spec.rb"]
  end

end

with_gem 'yard' do
  desc "Generate Yardoc"
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'README.markdown']
  end
end


