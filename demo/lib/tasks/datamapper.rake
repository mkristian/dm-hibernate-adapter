# this file is from dm-more/rails_datamapper
# add adjusted to use the rack_datamapper session store

# Monkey patch to allow overriding defined rake tasks (instead of
# adding to them, which is the default behaviour when specifying tasks
# >1 times).

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  returning Rake.application do |app|
    app.remove_task(app[task_name].name)
  end
end

# Until AR/DM co-existence becomes practically possible, presume
# mutual exclusivity between the two.  Thus we wipe all pre-existing
# db tasks which we assume to be ActiveRecord-based and thus won't
# work).

Rake.application.tasks.select do |t|
  t.class == Rake::Task && t.name.starts_with?("db")
end.each { |t| remove_task(t.name) }

namespace :db do

  desc 'Perform automigration'
  task :automigrate => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_migrate!
  end

  desc 'Perform non destructive automigration'
  task :autoupgrade => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_upgrade!
  end

  # this is needed for rspec and test tasks  
  namespace :test do
    task :prepare do
      RAILS_ENV='test'
      Rake::Task['db:automigrate'].invoke
    end
  end

  namespace :migrate do
    task :load => :environment do
      require 'dm-migrations/migration_runner'
      FileList['db/migrate/*.rb'].each do |migration|
        load migration
      end
    end

    desc 'Migrate up using migrations'
    task :up, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_up!(version)
    end

    desc 'Migrate down using migrations'
    task :down, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_down!(version)
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => 'db:migrate:up'

  namespace :sessions do
    desc "Creates the sessions table for rack DataMapperStore (works only with the default session class)"
    task :create => :environment do
      ::DataMapper::Session::Abstract::Session.auto_migrate!
    end

    desc "Clear the sessions table for rack DataMapperStore (works only with the default session class)"
    task :clear => :environment do
      ::DataMapper::Session::Abstract::Session.all.destroy!
    end
  end
end
