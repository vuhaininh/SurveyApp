Sequel::Model.plugin :validation_helpers

class Option < Sequel::Model
  mount_uploader :image, OptionUploader
  many_to_one :question
  one_to_many :option_translations

  def validate
    super
    validates_presence :question, :message => 'Options must belong to 1 question'
  end

  def optionText(languageCode = 'en-GB')
    optionTranslation = self.option_translations.select { |item| item[:language_code] == languageCode }.first
    if (!optionTranslation.nil?)
      return optionTranslation.content
    end
  end

  def setOptionText(text, languageCode = 'en-GB')
    optionTranslation = self.option_translations.select { |item| item[:language_code] == languageCode }.first
    if (optionTranslation.nil?)
      optionTranslation = OptionTranslation.new
      optionTranslation.option = self;
    end
    optionTranslation.content = text;
    optionTranslation.save
  end

  def clone(clone_question)
    begin
      co = Option.create do |o|
        o.question = clone_question
      end
      ot = OptionTranslation.create do |ot|
        ot.content = self.optionText
        ot.option = co
      end
      return co
    rescue
      return nil
    end
  end
end
