migration 20100511211400, :create_users do
  up do
    create_table :users do
      column :id, Integer, :serial => true
      column :name, String, :nullable => false, :length => 255
      column :created_at, DateTime, :nullable => false
      column :updated_at, DateTime, :nullable => false
    end
  end

  down do
    drop_table :users
  end
end
