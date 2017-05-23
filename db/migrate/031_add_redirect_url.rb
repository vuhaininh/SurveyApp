Sequel.migration do
  up do
    alter_table(:surveys) do
      add_column :redirect_url, String
    end
  end

end
