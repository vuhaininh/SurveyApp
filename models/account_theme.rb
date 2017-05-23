class AccountTheme < Sequel::Model
  many_to_one :account
  many_to_one :theme
end
