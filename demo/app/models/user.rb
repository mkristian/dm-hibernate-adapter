class User
  include DataMapper::Resource

  property :id, Serial

  property :name, String, :nullable => false , :format => /^[^<'&">]*$/, :length => 255

  timestamps :at

end
