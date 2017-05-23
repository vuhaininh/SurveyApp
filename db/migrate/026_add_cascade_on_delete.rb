Sequel.migration do
  up do
    alter_table(:survey_translations) do
      drop_foreign_key [:survey_id]
      add_foreign_key [:survey_id], :surveys, :on_delete => :cascade
    end
    alter_table(:question_translations) do
      drop_foreign_key [:question_id]
      add_foreign_key [:question_id], :questions, :on_delete => :cascade
    end
    alter_table(:question_type_translations) do
      drop_foreign_key [:question_type_id]
      add_foreign_key [:question_type_id], :question_types, :on_delete => :cascade
    end
    alter_table(:option_translations) do
      drop_foreign_key [:option_id]
      add_foreign_key [:option_id], :options, :on_delete => :cascade
    end
  end
end
