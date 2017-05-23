Sequel::Model.plugin :validation_helpers

class QuestionTranslation < Sequel::Model
	many_to_one :question

  def validate
    super
    validates_presence :question, :message => 'Translation must belong to 1 question'
  end
end
