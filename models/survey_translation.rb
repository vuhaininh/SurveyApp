class SurveyTranslation < Sequel::Model
	many_to_one :survey
end
