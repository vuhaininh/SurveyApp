Sequel.migration do
  up do
    alter_table(:surveys) do
      add_column :preview_image, String
    end
  end

end
