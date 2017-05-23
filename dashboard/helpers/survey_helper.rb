# Helper methods defined here can be accessed in any controller or view in the application

module Svipk
  class Dashboard
    module SurveyHelper

      def delete_survey_translations(survey)
        survey_translations = survey.survey_translations
        survey_translations.each { |st| st.delete }
      end

      def delete_survey_questions(survey)
        questions = survey.questions
        questions.each { |q| delete_question(q) }
      end

      def delete_survey(survey)
        delete_survey_translations(survey)
        delete_survey_questions(survey)
        delete_survey_feedbacks(survey)
        survey.delete
      end

      def delete_survey_feedbacks(survey)
        survey.feedbacks.each { |f| delete_feedback_answers(f) }
      end

      def delete_feedback_answers(feedback)
        feedback.answers.each { |a| a.delete }
        feedback.delete
      end

      def start_over_survey(survey)
        delete_survey_feedbacks(survey)
        survey.view_count = 0
        survey.save
      end



      def clone_questions(survey, clone)
        survey.questions.each { |question| clone_question(clone, question) }
      end

      def clone_question(clone, question)
        if !clone.nil? && !question.nil?
          clone_question = Question.create do |cq|
            cq.survey = clone
            cq.index = clone.questions.count + 1
            cq.question_type = question.question_type
          end
          clone_question_translation(clone_question, question)
          clone_options(clone_question, question)
        end
      end

    end

    def is_url_exist(custom_url)
      if custom_url.nil? || custom_url.strip.length == 0
        return false
      end
      custom_url = custom_url.strip.downcase
      begin
        path = Dashboard.recognize_path(custom_url) || Feedback.recognize_path(custom_url)
        return true
      rescue
        survey = Survey.find(:custom_url => custom_url)
        if (survey)
          return true
        end
      end
      return false
    end

    def get_custom_url(survey)
      if (survey.custom_url)
        return request.scheme + '://' + request.host_with_port + '/' + survey.custom_url
      end
    end

    def populate_survey_urls(survey)
      if (survey)
        short_host = ENV['SHORT_HOST'] || (request.scheme + '://' + request.host_with_port)
        survey.full_url = request.scheme + '://' + request.host_with_port + '/s/' + OID.encode(survey.id)
        survey.short_url = short_host + '/s/' + OID.encode(survey.id)
        if (survey.custom_url)
          survey.full_custom_url = request.scheme + '://' + request.host_with_port + '/' + survey.custom_url
          survey.short_custom_url = short_host + '/' + survey.custom_url
        end
      end
    end

    helpers SurveyHelper
  end
end
