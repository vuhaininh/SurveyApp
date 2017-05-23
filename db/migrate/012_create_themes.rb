Sequel.migration do
  up do
    create_table :themes do
      primary_key :id
	    foreign_key :account_id, :accounts
      String :name
	    String :logo
	    String :layout_name
    end
  end

  down do
    drop_table :themes
  end
end
