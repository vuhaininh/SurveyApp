Sequel.migration do
  up do
    create_table :questions do
      primary_key :id
	  foreign_key :survey_id, :surveys
	  foreign_key :question_type_id, :question_types
	  
	  Integer :index, null: false # question index on survey
	  
      DateTime :created_at
      DateTime :updated_at   
      
    end
  end

  down do
    drop_table :questions
  end
end
