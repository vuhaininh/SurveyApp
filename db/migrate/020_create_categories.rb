Sequel.migration do
  up do
    create_table :categories do
      primary_key :id
	  foreign_key :account_id, :accounts
	  String :name, null: false
      DateTime :created_at
      DateTime :updated_at       
    end
  end

  down do
    drop_table :categories
  end
end
