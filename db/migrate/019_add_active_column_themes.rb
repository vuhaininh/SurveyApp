Sequel.migration do
  change do
    alter_table(:themes) do
      add_column :active, TrueClass, :default => true
    end
  end
end
