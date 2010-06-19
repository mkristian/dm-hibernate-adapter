class User
  include DataMapper::Resource

  property :id, Serial

  property :name, String, :required => true , :format => /^[^<'&">]*$/, :length => 255

  timestamps :at

end
