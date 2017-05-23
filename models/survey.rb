Sequel::Model.plugin :validation_helpers
class Survey < Sequel::Model
  mount_uploader :preview_image, SurveyPreviewUploader
  many_to_one :account
  many_to_one :theme
  one_to_many :survey_translations
  one_to_many :questions
  one_to_many :feedbacks

  attr_accessor :full_url, :short_url, :full_custom_url, :short_custom_url

  def validate
    super
    validates_format /^[a-zA-Z0-9_-]*$/i, :custom_url, :message => 'Custom url is not valid, can contain only alphabetic, number, hyphen(-) and underscore(_) character.', :allow_blank => true
    validates_unique :custom_url,
                     :message => 'This custom url has been choosen. Please pick another one.',
                     :where => (proc do |ds, obj, cols|
                       ds.where(cols.map do |c|
                         v = obj.send(c)
                         v = v.downcase if v
                         [Sequel.function(:lower, c), v] if v
                       end)

                     end), :allow_blank => true
    validates_format /^https?:\/\/[\S]+$/, :redirect_url, :message => 'Invalid redirect url', :allow_blank => true
    validates_presence :name, :message => 'Survey must have name provided'
  end

  def oid
    OID.encode id
  end

  def question_count
    questions.count
  end

  def description(languageCode = 'en-GB')
    translation = self.survey_translations.select { |item| item[:language_code] == languageCode }.first
    if (!translation.nil?)
      return translation.description
    end
    return ''
  end

  def self.status
    ['draft', 'active', 'finished']
  end

  def clone
    begin
      clone_survey = Survey.new
      clone_survey.account = self.account
      clone_survey.theme_id = self.theme_id
      clone_survey.index = self.account.surveys.count + 1
      clone_survey.name = "Copy of " + self.name
      clone_survey.status = 'draft'
      if clone_survey.valid?
        clone_survey.save
      end

      clone_translation = SurveyTranslation.create do |t|
        t.survey = clone_survey
        t.description = self.survey_translations.first.description
      end

      self.questions.each { |question| question.clone(clone_survey) }
    rescue Exception => e
      return nil
    end
  end

  def to_JSON
    return {
        ID: self.id,
        Code: self.oid,
        Name: self.name,
        AutoReset: self.auto_reset,
        AutoResetInterval: self.auto_reset_interval,
        RedirectUrl: self.redirect_url,
        CustomUrl: self.custom_url,
        Questions: self.questions.map{|q| {
            :ID => q.id,
            :Index => q.index,
            :QuestionText => q.questionText,
            :QuestionType => q.question_type_id,
            :Choices => q.options.map{|op| {
                :Label => op.optionText
            }},
            :AllowMultipleChoice => q.question_type_id == 2 ? q.actual.multiple_selection : false
        }},
        Theme: self.theme.id.to_s,
        Created: self.created_at,
        Modified: self.updated_at
    }.to_json
  end
end
