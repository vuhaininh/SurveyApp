Sequel.migration do
  up do
	alter_table(:uploads) do
		add_foreign_key :category_id, :categories
	end
  end

  down do
	alter_table(:uploads) do
		drop_foreign_key :category_id
	end
  end
end
