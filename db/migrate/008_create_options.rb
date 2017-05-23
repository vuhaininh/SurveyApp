Sequel.migration do
  up do
    create_table :options do
      primary_key :id
	  foreign_key :question_id, :questions
      DateTime :created_at
      DateTime :updated_at   
      
    end
  end

  down do
    drop_table :options
  end
end
