module DataMapper
  def self.finalize
    Model.descendants.each do |model|
      finalize_model(model)
      model.hibernate!
    end
    self
  end

end
