class Feedback < Sequel::Model
  many_to_one :survey
  one_to_many :answers

  def parsed_answers
    @questions ||= survey.questions

    @answer = Answer.where(feedback: self).all

    result = []
    for question in @questions
      if question.question_type_id != 6
        answer = @answer.select { |a| a.question_id == question.id }
        if answer[0] != nil
          if question.question_type_id == 4
            case answer[0].content
              when "1"
                result << "Bored"
              when "2"
                result << "Normal"
              when "3"
                result << "Happy"
              when "4"
                result << "Excited"
            end
          else
            result << answer[0].content
          end
        else
          result << ""
        end
      end
    end

    return result
  end

  def to_csv
    self.attributes.values_at(*column_names)
  end
end
