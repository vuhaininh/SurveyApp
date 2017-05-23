def create_languages
  Language.create do |t|
    t.language_code = "en-GB"
    t.language_name = "English (United Kingdom)"
  end
end