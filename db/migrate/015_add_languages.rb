Sequel.migration do
  change do
    create_table(:languages) do
      primary_key :language_code, String
      column :language_name, String
	  end
  end
end
