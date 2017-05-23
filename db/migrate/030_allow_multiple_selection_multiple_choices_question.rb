Sequel.migration do
  up do
    alter_table(:multiple_choices_questions) do
      add_column :multiple_selection, TrueClass, :default => false
    end
  end

end
