if RUBY_PLATFORM =~ /java/
  require 'zlib'
  class Zlib::GzipWriter
    def <<(arg)
      write(arg)
    end
  end
end

require 'dm-timestamps'
require 'jibernate'

#TODO remove that hack
User.auto_migrate!
DataMapper::Session::Abstract::Session.auto_migrate!
