Sequel::Model.plugin :validation_helpers
class Question < Sequel::Model
  plugin :class_table_inheritance
  many_to_one :survey
  many_to_one :question_type
  one_to_many :question_translations
  one_to_many :options
  one_to_many :answers

  #image and video uploader
  #mount_uploader :video, QuestionVideoUploader
  #mount_uploader :image, QuestionImageUploader
  def validate
    super
    validates_presence :question_type, :message => 'Question must be in specific question type'
    validates_presence :survey, :message => 'Question must belong to 1 survey'
  end

  def questionText(languageCode = 'en-GB')
    questionTranslation = self.question_translations.select { |item| item[:language_code] == languageCode }.first
    if (!questionTranslation.nil?)
      return questionTranslation.content
    end
  end

  def setQuestionText(text, languageCode = 'en-GB')
    questionTranslation = self.question_translations.select { |item| item[:language_code] == languageCode }.first
    if (questionTranslation.nil?)
      questionTranslation = QuestionTranslation.new
      questionTranslation.question = self;
    end
    questionTranslation.content = text;
    questionTranslation.save
  end

  def actual
    actualQuestion = nil
    case self.question_type_id
      when QuestionType::STAR_RATING
        actualQuestion = StarRatingQuestion[self.id]
      when QuestionType::MULTIPLE_CHOICES
        actualQuestion = MultipleChoicesQuestion[self.id]
      when QuestionType::TEXT_INPUT
        actualQuestion = TextQuestion[self.id]
      when QuestionType::IMAGE
        actualQuestion = ImageQuestion[self.id]
      when QuestionType::INFO
        actualQuestion = InfoPageQuestion[self.id]
      else
        return self
    end
    return actualQuestion ? actualQuestion : self;

  end

  def result
    @result ||= Result.new (self.actual)
  end

  def clone_question(clone_survey)
    begin
      clone_question = self.class.create do |cq|
        if clone_survey
          cq.survey = clone_survey
          cq.index = clone_survey.questions.count + 1
        end
        cq.question_type = self.question_type
      end
      clone_question.setQuestionText(self.questionText)

      self.options.each { |option|
        option.clone(clone_question)
      }
      return clone_question
    rescue
      return nil
    end
  end
  def clone(clone_survey)
    return self.actual.clone_question(clone_survey)
  end
end
