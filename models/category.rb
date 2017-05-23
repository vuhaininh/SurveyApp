class Category < Sequel::Model
	many_to_one :account
	one_to_many :uploads
end
