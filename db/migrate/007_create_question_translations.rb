Sequel.migration do
  up do
    create_table :question_translations do
      primary_key :id
      foreign_key :question_id, :questions
	  Text :content
	  String :language_code, default: 'en-EN'
	  
      DateTime :created_at
      DateTime :updated_at   
    end
  end

  down do
    drop_table :question_translations
  end
end
