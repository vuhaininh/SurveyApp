Sequel.migration do
  up do
    create_table :survey_translations do
      primary_key :id
	  foreign_key :survey_id, :surveys
      Text :description
	  String :language_code, default: 'en-EN'
	  
      DateTime :created_at
      DateTime :updated_at   
    end
  end

  down do
    drop_table :survey_translations
  end
end
