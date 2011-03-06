require 'rake'
require 'rake/gempackagetask'

SPEC_LOCATIONS = {
  :abstract_adapter => "spec/abstract_adapter",
  :dm_core          => "spec/dm_core",
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

    desc 'Run transient specs'
    Spec::Rake::SpecTask.new(:transient) do |t|
      if File.exists?("#{SPEC_LOCATIONS[:transient]}/spec.opts")
        t.spec_opts << '--options' << "#{SPEC_LOCATIONS[:transient]}/spec.opts"
      end
      t.libs << 'lib'
      t.spec_files = FileList["#{SPEC_LOCATIONS[:transient]}/dm-hibernate-adapter_spec.rb"]
    end
  end

end

with_gem 'yard' do
  desc "Generate Yardoc"
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'README.markdown']
  end
end

specification = Gem::Specification.new do |s|
  s.name = "dm-hibernate-adapter"
  s.summary = "dm-hibernate-adapter = DM + Hibernate"
  s.version = "0.0.1"
  s.author = 'Kristian Meier Piotr Gega Douglas Ferreira'
  s.description = s.summary
  #s.homepage = 'http://ribs.rubyforge.org'
  #s.rubyforge_project = 'ribs'

  s.has_rdoc = false
  #s.extra_rdoc_files = ['README.']
  #s.rdoc_options << '--title' << 'ribs' << '--main' << 'README' << '--line-numbers'

  s.email = 'piotrgega@gmail.com'
  s.files = FileList['{lib,spec}/**/*.{rb,jar}', '[A-Z]*$', 'Rakefile'].to_a
  s.add_dependency('dm-core', '1.0.0')
  s.add_dependency('dm-transactions', '1.0.0')
  s.add_dependency('dm-migrations', '1.0.0')
  s.add_dependency("slf4r", "0.3.1")
end

Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = false
  package.need_tar = false
end

