Svipk::Dashboard.controllers :question do
  before do
    @survey = Survey.where(account_id: @user.id).where(index: params[:survey_index]).first
    @question = Question.where(survey: @survey).where(index: params[:question_index]).first

    if @survey.nil? || @question.nil?
      redirect url :list, :index
    end
  end

  # ugly route, considering rename
  post :edit, map: '/survey/:survey_index/question/:question_index/edit', :provides => [:json, :html] do
    case content_type
      when :json
        begin
          updatedRequest = Oj.load(request.body.read)
          if (updatedRequest)
            updatedQuestion = updatedRequest['question']
            if (updatedQuestion)
              q_type = QuestionType.where(id: updatedQuestion['questionTypeId']).first
              @question.question_type_id = q_type.id
              @question.setQuestionText(updatedQuestion['questionText'])
              actualQuestion = @question.actual
              if(q_type.id == QuestionType::MULTIPLE_CHOICES)
                actualQuestion.multiple_selection = updatedQuestion['multipleSelection']
              end
              actualQuestion.save
              @question.remove_all_options
              create_options(@question, updatedQuestion['options'])
              return {status: 0, message: 'Updated question successfully'}.to_json
            end
          end
        rescue Exception => e
          return {status: 1, message: e.message}.to_json
        end
      else
        form = params[:question] #TODO validation
        q_type = QuestionType.where(id: form[:type].to_i).first
        @question.question_type_id = q_type.id
        @question.setQuestionText(form[:name])
        @question.options.each { |o| delete_option(o) }
        create_options(@question, form[:multiple_choice])
        @question.save
        redirect url :survey, :questions, survey_index: @survey.index

    end
  end

  get :delete, map: '/survey/:survey_index/question/:question_index/delete', :provides => [:json, :html] do

    # Get all question that have index larger than current question
    above_questions = @survey.questions
    above_questions.sort! { |a, b| a.index<=> b.index }

    # Reposition by subtract each question index by 1
    above_questions.each do |question|
      if (question.index > @question.index)
        question.index -= 1
        question.save
      end
    end

    # Finally delete current question
    delete_question(@question)

    case content_type
      when :json
        return {status: 1, message: 'Question has been deleted!'}.to_json
      else
        # Return to question list after done
        # TODO render question list if request is ajax
        redirect url :survey, :questions, survey_index: @survey.index
    end
  end

end
