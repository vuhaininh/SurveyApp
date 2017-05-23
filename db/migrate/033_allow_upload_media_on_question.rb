Sequel.migration do
  up do
    alter_table(:questions) do
      add_column :files, JSON
    end
    alter_table(:options) do
      drop_column :upload_id
    end
  end

  down do
    alter_table(:questions) do
      drop_column :files
    end
    alter_table(:options) do
      #add_column :image String
    end
  end

end
