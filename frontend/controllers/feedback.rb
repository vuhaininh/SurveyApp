Svipk::Frontend.controllers :feedback do
  get :index, map: '/:id' , :provides => [:json, :html] do
    if(params[:id])
      @id = OID.decode params[:id]
      if(@id)
        @survey = Survey[OID.decode params[:id]]
      end
      if @survey.nil?
        @survey = Survey.first(Sequel.function(:lower, :custom_url) => params[:id].downcase)
      end
      if @survey
        @survey.view_count += 1
        @survey.save
        @css = '/assets/frontendapp/theme'+@survey.theme.id.to_s+'/application'
        case content_type
          when :json
            return @survey.to_JSON
          when :html
            return render 'feedback/index'
        end
      end

    end
    status 404
  end

  post :index, map: '/:id', :provides => :any do
    case content_type
      when :html
        @id = OID.decode params[:id]

        @survey = Survey[OID.decode params[:id]]
        if @survey.status == 'active'
          answers = params[:question]

          feedback = Feedback.new
          feedback.survey = @survey
          feedback.index = @survey.feedbacks.count + 1
          feedback.ip = request.ip
          feedback.user_agent = request.user_agent
          feedback.referer = request.referer
          result = feedback.save

          if  answers != nil
            answers.each do |index, answer|
              question = Question.where(survey: @survey).where(index: index).first

              # Check if question exists, belongs to current survey and not an empty string (for input field)
              if question and answer
                question = question.actual
                case question.question_type_id
                  when QuestionType::MULTIPLE_CHOICES
                    if question.multiple_selection && answer.kind_of?(Array)
                      answer = answer.join(",")
                    end
                    Answer.create do |a|
                      a.feedback = feedback
                      a.question = question
                      a.index = question.answers.count + 1
                      a.content = answer
                    end
                  else
                    Answer.create do |a|
                      a.feedback = feedback
                      a.question = question
                      a.index = question.answers.count + 1
                      a.content = answer
                    end
                end
              end
            end
          end
        end
        return;
      when :json
        updatedRequest = Oj.load(request.body.read)
        result = true
        if (updatedRequest)
          answers = updatedRequest['Answers']
          @survey = Survey[updatedRequest['SurveyID']]
          if(@survey.nil?)
            return true.to_json
          end
          feedback = Feedback.new
          feedback.survey = @survey
          feedback.index = @survey.feedbacks.count + 1
          feedback.ip = request.ip
          feedback.user_agent = request.user_agent
          feedback.referer = request.referer
          feedback.created_at = updatedRequest['Created']
          result = feedback.save != nil
          if (answers != nil)
            answers.each do |answer|
              question = Question.where(survey: @survey).where(id: answer['QuestionId']).first

              # Check if question exists, belongs to current survey and not an empty string (for input field)
              if question and answer
                a = Answer.new
                a.feedback = feedback
                a.question = question
                a.index = question.answers.count + 1
                a.content = answer['Content']
                result = result != nil  && a.save != nil
              end
            end
          end
        end
        return result.to_json;
    end

  end

end
