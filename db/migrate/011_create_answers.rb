Sequel.migration do
  up do
    create_table :answers do
      primary_key :id
	  foreign_key :question_id, :questions
	  foreign_key :feedback_id, :feedbacks
	  Text :content, default: ''
	  Integer :index, null: false # answer index on question
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :answers
  end
end
