Sequel.migration do
  change do
    alter_table(:surveys) do
      add_column :full_screen, TrueClass, :default => false
      add_column :auto_reset, TrueClass, :default => true
      add_column :auto_reset_interval, Integer, :default => 10
    end
  end
end
