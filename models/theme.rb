class Theme < Sequel::Model
  many_to_one :created_by, :class => "Account"
  one_to_many :surveys
  many_to_one :theme_type
  many_to_many :assigned_users, :class => :Account, :join_table => :account_themes, :left_key => :theme_id, :right_key => :account_id

  def theme_type_description(language_code)
    return self.theme_type.theme_type_translations.find(:language_code=>language_code).first().theme_type_description
  end

  def no_of_surveys
    return self.surveys.count
  end
end
