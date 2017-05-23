class QuestionTypeTranslation < Sequel::Model
	many_to_one :question_type
end
