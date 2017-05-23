Sequel.migration do
  change do
    create_table (:countries) do
      primary_key :country_id, Integer
      column :country_name, String
      foreign_key :language_code, :languages, :type=>String
      column :country_phone_code, Integer, :unique=>true
    end
    alter_table(:accounts) do
      add_column :address, String
      add_column :phone_number, String
      add_foreign_key :country, :countries
      add_foreign_key :prefer_language, :languages, :type=>String
    end
  end
end
