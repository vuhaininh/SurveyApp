Sequel.migration do
  up do
    create_table :surveys do
      primary_key :id
	  foreign_key :account_id, :accounts
      Integer :index, null: false # survey index on account
      String :name, null: false
      

      String :full_url
      String :short_url
      String :qrcode_url
	  String :default_language, default: "en-EN"

      # State of survey: unfinished (draft), publishing (active) or completed (finished)
      String :status, null: false, default: 'draft'

      # How many time the survey is visited
      Integer :view_count, null: false, default: 0

      DateTime :created_at
      DateTime :updated_at
      DateTime :published_at
      DateTime :finished_at
    end
  end

  down do
    drop_table :surveys
  end
end
