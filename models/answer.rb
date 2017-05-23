class Answer < Sequel::Model
	many_to_one :feedback
	many_to_one :question
end
