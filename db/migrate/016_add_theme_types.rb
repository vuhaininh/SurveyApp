Sequel.migration do
  change do
    create_table(:theme_types) do
      primary_key :theme_type_id, Integer
      column :available_for_all, TrueClass
    end

    create_table(:theme_type_translations) do
      foreign_key :theme_type_id, :theme_types
      foreign_key :language_code, :languages, :type=>String
      primary_key [:theme_type_id, :language_code]
      column :theme_type_description, String, :size=>255
    end

    alter_table(:themes) do
      add_foreign_key :theme_type_id, :theme_types
    end

  end
end
