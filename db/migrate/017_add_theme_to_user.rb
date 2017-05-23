Sequel.migration do
  change do
    create_table(:account_themes) do
      foreign_key :account_id, :accounts
      foreign_key :theme_id, :themes
      primary_key [:account_id, :theme_id]
      DateTime :activate_date
      DateTime :expire_date
      DateTime :assigned_date
      foreign_key :assigned_by, :accounts
    end

    alter_table(:themes) do
      rename_column :account_id, :created_by_id
    end
  end
end
