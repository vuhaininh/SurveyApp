Sequel.migration do
  up do
    create_table :accounts do
      primary_key :id
      String :first_name, null: false
      String :last_name, null: false

      String :email, index: {unique: true}
      Boolean :email_confirmation, default: false

      String :crypted_password, null: false
      String :remember_token
      String :role, null: false, default: 'user'

      DateTime :created_at
      DateTime :updated_at

    end


  end

  down do
    drop_table :accounts
  end
end
