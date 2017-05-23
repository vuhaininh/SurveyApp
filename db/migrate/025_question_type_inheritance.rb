Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :media_option, Integer
      add_column :video_url, String
      add_column :image_url, String
    end
    create_table(:image_questions) do
      primary_key :id
      column :multiple_selection, TrueClass, :default=>false
      column :display_label, TrueClass, :default=>true
    end
    create_table(:multiple_choices_questions) do
      primary_key :id
      column :allow_other_choice, TrueClass, :default => false
      column :force_vertical_alignment, TrueClass, :default => false
    end
    create_table(:star_rating_questions) do
      primary_key :id
      column :icon, String
    end
    create_table(:text_questions) do
      primary_key :id
      column :require, TrueClass, :default => false
    end
    create_table(:smile_face_questions) do
      primary_key :id
    end
  end
end
