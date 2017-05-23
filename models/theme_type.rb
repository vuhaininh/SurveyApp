class ThemeType < Sequel::Model
  one_to_many :theme_type_translations
  one_to_many :themes
end
