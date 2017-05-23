# Helper methods defined here can be accessed in any controller or view in the application

module Svipk
  class Dashboard
    module QuestionHelper
      def create_options(question, choices)
        case question.question_type_id
          when QuestionType::MULTIPLE_CHOICES
            for choice in choices.split(',')
              o = Option.create do |o|
                o.question = question
              end
              create_option_translation(o, choice)
            end
        end
      end

      def create_image_options(question, images)
        #TODO: enable multiple upload
        for imageInfo in images
          option = Option.new
          optionUploader = OptionUploader.new(option, :image)
          optionUploader.retrieve_from_cache!(imageInfo[:cacheId])
          option.question = question
          option.image = optionUploader.file
          option.save
          create_option_translation(option, imageInfo[:label])
        end
      end

      def create_option_translation(option, content)
        o = OptionTranslation.create do |o|
          o.content = content
          o.option = option
        end
      end

      def create_question_translation(question, content)
        QuestionTranslation.create do |q|
          q.question = question
          q.content = content
        end
      end

      def delete_option(option)
        option.option_translations.each { |ot| delete_option_translation(ot) }
        option.delete
      end

      def create_question(form)
        q_type = QuestionType.where(id: form[:type].to_i).first
        question = nil
        result = nil

        case q_type.id
          when QuestionType::STAR_RATING
            question = StarRatingQuestion.new
          when QuestionType::MULTIPLE_CHOICES
            question = MultipleChoicesQuestion.new
            question.multiple_selection = form[:multiple_selection] == 'on' ? true:false;
          when QuestionType::TEXT_INPUT
            question = TextQuestion.new
          when QuestionType::SMILE_FACE
            question = Question.new
          when QuestionType::IMAGE
            question = ImageQuestion.new
            question.multiple_selection = form[:multiple_selection] == 'on' ? true:false;
          when QuestionType::INFO
            question = InfoPageQuestion.new
        end
        question.survey = @survey
        question.index = @survey.questions.count + 1
        question.question_type = q_type

        if (question.valid?)
          DB.transaction do
            DB.after_rollback{result = {:status_code => false, :errors => question.errors}}
            DB.after_commit{result = {:status_code => true}}
            saveResult = question.save
            if saveResult.nil?
              raise Sequel::Rollback
            end
            translation = QuestionTranslation.new
            if (q_type.id == QuestionType::INFO)
              translation.content = form[:info]
            else
              translation.content = form[:name]
            end
            question.add_question_translation(translation)
            case q_type.id
              when QuestionType::MULTIPLE_CHOICES
                create_options(question, form[:multiple_choice])
              when QuestionType::IMAGE
                create_image_options(question, form[:images])
            end
          end
        else
          result = {:status_code => false, :errors => question.errors}
        end
        return result
      end

      def delete_option_translation(option_translation)
        option_translation.delete
      end

      def delete_answers(question)
        question.answers.each { |a| a.delete }
      end

      def delete_question(question)
        delete_answers(question)
        question.question_translations.each { |t| t.delete }
        question.options.each { |o| delete_option(o) }
        question.delete
      end
    end
    helpers QuestionHelper
  end
end
