class ThemeTypeTranslation < Sequel::Model
  many_to_one :theme_type
end
