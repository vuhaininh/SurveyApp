Sequel.migration do
  up do
	alter_table(:surveys) do
		add_foreign_key :theme_id, :themes
	end
  end

  down do
	alter_table(:surveys) do
		drop_foreign_key :theme_id
	end
  end
end
