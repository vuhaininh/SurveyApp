Sequel.migration do
  up do
    alter_table(:question_types) do
      add_column :active, TrueClass, :default => true
    end

  end

  down do
    alter_table(:question_types) do
      drop_column :active
    end
  end
end
