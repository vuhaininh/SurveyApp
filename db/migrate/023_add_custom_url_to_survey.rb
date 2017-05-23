Sequel.migration do
  up do
    alter_table(:surveys) do
      drop_column :full_url
      drop_column :short_url
      add_column :custom_url, String, :unique => true
    end
  end

  down do
    alter_table(:surveys) do
      add_column :full_url, String
      add_column :short_url, String
      drop_column :custom_url
    end
  end
end
