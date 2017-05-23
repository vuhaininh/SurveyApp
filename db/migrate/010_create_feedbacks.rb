Sequel.migration do
  up do
    create_table :feedbacks do
      primary_key :id
	  foreign_key :survey_id, :surveys
	  String :language_code, default: 'en-EN'
	  
      Integer :index, null: false # feedback index on survey

      column :ip, :inet, null: false # ipv4 address
      String :user_agent
      String :referer # linked from	  
	  
      DateTime :created_at
      DateTime :updated_at    
    end
  end

  down do
    drop_table :feedbacks
  end
end
