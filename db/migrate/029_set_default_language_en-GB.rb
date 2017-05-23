Sequel.migration do
  up do
    alter_table(:surveys) do
      DB.run "UPDATE surveys SET default_language = 'en-GB'"
      set_column_default(:default_language, 'en-GB')
      add_foreign_key [:default_language], :languages
    end
    alter_table(:survey_translations) do
      DB.run "UPDATE survey_translations SET language_code = 'en-GB'"
      set_column_default(:language_code, 'en-GB')
      add_foreign_key [:language_code], :languages
    end
    alter_table(:question_type_translations) do
      DB.run "UPDATE question_type_translations SET language_code = 'en-GB'"
      set_column_default(:language_code, 'en-GB')
      add_foreign_key [:language_code], :languages
    end
    alter_table(:question_translations) do
      DB.run "UPDATE question_translations SET language_code = 'en-GB'"
      set_column_default(:language_code, 'en-GB')
      add_foreign_key [:language_code], :languages
    end
    alter_table(:option_translations) do
      DB.run "UPDATE option_translations SET language_code = 'en-GB'"
      set_column_default(:language_code, 'en-GB')
      add_foreign_key [:language_code], :languages
    end
    alter_table(:feedbacks) do
      DB.run "UPDATE feedbacks SET language_code = 'en-GB'"
      set_column_default(:language_code, 'en-GB')
      add_foreign_key [:language_code], :languages
    end
  end

end
