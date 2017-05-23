Sequel.migration do
  up do
    create_table :question_types do
      primary_key :id  
	  
      DateTime :created_at
      DateTime :updated_at   
    end
  end

  down do
    drop_table :question_types
  end
end
