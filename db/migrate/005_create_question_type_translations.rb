Sequel.migration do
  up do
    create_table :question_type_translations do
      primary_key :id
	  foreign_key :question_type_id, :question_types
	  String :name, null: false
	  String :language_code, default: 'en-EN'
	  
      DateTime :created_at
      DateTime :updated_at   
      
    end
  end

  down do
    drop_table :question_type_translations
  end
end
