Sequel.migration do
  up do
    create_table :uploads do
      primary_key :id
      Text :file
      DateTime :created_at
	  
    end
  end

  down do
    drop_table :uploads
  end
end
