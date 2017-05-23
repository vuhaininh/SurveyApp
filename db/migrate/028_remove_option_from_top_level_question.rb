Sequel.migration do
  up do
    run "INSERT INTO star_rating_questions(id)
            SELECT id from questions WHERE question_type_id = '1' and id not in (SELECT id FROM star_rating_questions)"

    run "INSERT INTO multiple_choices_questions(id)
            SELECT id from questions WHERE question_type_id = '2' and id not in (SELECT id FROM multiple_choices_questions)"

    run "INSERT INTO text_questions(id)
            SELECT id from questions WHERE question_type_id = '3' and id not in (SELECT id FROM text_questions)"

    run "INSERT INTO smile_face_questions(id)
            SELECT id from questions WHERE question_type_id = '4' and id not in (SELECT id FROM smile_face_questions)"

    run "INSERT INTO image_questions(id)
            SELECT id from questions WHERE question_type_id = '5' and id not in (SELECT id FROM image_questions)"

    run "INSERT INTO info_page_questions(id)
            SELECT id from questions WHERE question_type_id = '6' and id not in (SELECT id FROM info_page_questions)"

  end
  down do

  end
end
