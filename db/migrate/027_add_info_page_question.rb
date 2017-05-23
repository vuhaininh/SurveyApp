Sequel.migration do
  up do
    create_table(:info_page_questions) do
      primary_key :id
    end
    #run "INSERT INTO question_types(id) VALUES(6); INSERT INTO question_type_translations(question_type_id, name) VALUES(6, 'Information Page')"
  end
  down do

  end

end
