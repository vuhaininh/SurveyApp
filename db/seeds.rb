require File.expand_path('../seeds/create_languages', __FILE__)

def create_admin()
  user = Account.create do |u|
    u.email = 'haininh.vu89@gmail.com'
    u.password = 'Smile222'
    u.password_confirmation = 'Smile222'
    u.first_name = 'Admin'
    u.last_name = 'Super'
    u.email_confirmation = true
    u.role = 'admin'
  end
end

def create_sample_survey(user)

  survey = Survey.create do |s|
    s.theme = Theme.first
    s.account = user
    s.index = user.surveys.count + 1
    s.status = Survey.status.sample
    s.name = Faker::Name.name

    s.default_language = "en-GB"

    if s.status == 'finished'
      s.finished_at = Time.now
    end
  end

  if survey.status != 'draft'
    survey.published_at = Time.now
    survey.save
  end

  create_sample_survey_translation(survey)

  (Random.new.rand(5..10)).times { create_sample_question(survey) }


  (Random.rand(50) + 10).times { create_sample_feedback(survey) }
end

def create_sample_survey_translation(survey)
  translation = SurveyTranslation.create do |t|
    t.survey = survey
    t.description = Faker::Lorem.paragraph(5)
    t.language_code = "en-GB"
  end
end

def create_sample_feedback(survey)
  user_agents = ['Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)', 'AppleWebKit/536.5 (KHTML, like Gecko)', 'Chrome/19.0.1084.56', 'Safari/536.5']

  feedback = Feedback.create do |f|
    f.survey = survey
    f.index = survey.feedbacks.count + 1

    f.ip = Faker::Internet.ip_v4_address
    f.user_agent = user_agents.sample
    f.referer = Faker::Internet.url
  end

  Question.where(survey: survey).each do |question|
    create_sample_answer(feedback, question)
  end

end

def create_sample_answer(feedback, question)
  answer = Answer.create do |a|
    a.question = question
    a.feedback = feedback
    a.index = question.answers.count + 1
    if (question.question_type_id == 1)
      a.content = Random.new.rand(1..5).to_s
    end
    if (question.question_type_id == 4)
      a.content = Random.new.rand(1..4).to_s
    end
    if (question.question_type_id == 2 or question.question_type_id == 5)
      ncount = question.options.count
      index = ncount-1
      pos = Random.new.rand(0..index)
      option = question.options[pos]
      otran = OptionTranslation[:option_id => option.id]
      a.content = otran[:content]
    end
    if (question.question_type_id == 3)
      a.content = Faker::Lorem.sentence
    end
  end
end

def create_sample_question(survey)
  question = Question.new

  question.survey = survey
  question.index = survey.questions.count + 1
  question.question_type = QuestionType.all[Random.new.rand(0..3)]
  question.save
  create_sample_question_translation(question)
  create_sample_option(question)
end

def create_sample_question_translation(question)
  QuestionTranslation.create do |q|
    q.question = question
    q.content = Faker::Lorem.sentence.tr('.', '?')
  end
end

def create_sample_option(question)
  if (question.question_type_id == 1)
    i = 1
    while i <= 5 do
      o = Option.create do |o|
        o.question = question
      end
      create_sample_option_translation(o, i.to_s)
      i +=1
    end
  end
  if (question.question_type_id == 4)
    i = 1
    while i <= 4 do
      o = Option.create do |o|
        o.question = question
      end
      create_sample_option_translation(o, i.to_s)
      i +=1
    end
  end
  if (question.question_type_id == 2)
    a = Random.new.rand(4..8)
    a.times do
      o = Option.create do |o|
        o.question = question
      end
      create_sample_option_translation(o, Faker::Lorem.words(6).map(&:capitalize).first)
    end
  end
  if (question.question_type_id == 3)
    o = Option.create do |o|
      o.question = question
    end
    create_sample_option_translation(o, "")
  end
end

def create_sample_option_translation(option, content)
  o = OptionTranslation.create do |o|
    o.content = content
    o.option = option
  end
end

def create_sample_question_type
  type1 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type1, "Star Rating")

  type2 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type2, "Multiple Choice")

  type3 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type3, "Text Input")

  type4 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type4, "Smiley Faces")

  type5 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type4, "Image Question")

  type6 = QuestionType.create do |t|
  end
  create_sample_question_type_translation(type4, "Info Page")


end

def create_sample_question_type_translation(type, name)
  QuestionTypeTranslation.create do |t|
    t.question_type = type
    t.name = name
  end
end

def create_sample_data(user)
  create_sample_question_type
  #(Random.rand(10) + 10).times { create_sample_survey(user) }

end

def create_sample_theme()
  basic_theme_type = ThemeType.create do |t|
    t.available_for_all = true
  end
  ThemeTypeTranslation.create do |t|
    t.theme_type_id = basic_theme_type.theme_type_id
    t.theme_type_description = "Basic Theme"
    t.language_code = "en-GB"
  end

  pre_theme_type = ThemeType.create do |t|
    t.available_for_all = false
  end
  ThemeTypeTranslation.create do |t|
    t.theme_type_id = pre_theme_type.theme_type_id
    t.theme_type_description = "Premium Theme"
    t.language_code = "en-GB"
  end

  theme = Theme.create do |t|
   t.created_by = Account.first
   t.name = "Theme 1"
    t.theme_type_id = basic_theme_type.theme_type_id
  end
end

Sequel::Model.db.transaction do
  #admin = create_admin()
  #create_languages
  create_sample_theme()
  #create_sample_data(admin)
end