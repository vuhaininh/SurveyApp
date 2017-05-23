Sequel.migration do
  up do
	alter_table(:options) do
		add_column :upload_id, Integer
	end
  end

  down do
	alter_table(:options) do
		drop_column :upload_id
	end
  end
end
