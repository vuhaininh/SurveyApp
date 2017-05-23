Sequel::Model.plugin :validation_helpers

class OptionTranslation < Sequel::Model
	many_to_one :option
  def validate
    super
    validates_presence :option, :message => 'Translation must belong to 1 option'
  end
end
