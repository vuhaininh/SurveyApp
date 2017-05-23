class QuestionType < Sequel::Model
	one_to_many :question_type_translations
	one_to_many :questions

  STAR_RATING = 1
  MULTIPLE_CHOICES = 2
  TEXT_INPUT = 3
  SMILE_FACE = 4
  IMAGE = 5
  INFO = 6
end
