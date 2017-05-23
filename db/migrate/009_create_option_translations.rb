Sequel.migration do
  up do
    create_table :option_translations do
      primary_key :id
	  foreign_key :option_id, :options
      Text :content
	  String :language_code, default: 'en-EN'
      DateTime :created_at
      DateTime :updated_at   
    end
  end

  down do
    drop_table :option_translations
  end
end
