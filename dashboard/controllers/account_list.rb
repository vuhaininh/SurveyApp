Svipk::Dashboard.controllers :account_list do
  get :index, map: '/accounts' do
    @accounts= Account.all
	  render 'account_list/index'
  end
  post :new_account, map: '/new-account' do
    account_form = params[:account] # TODO: validation

	Account.create do |u|
		u.first_name = account_form[:first_name]
		u.last_name = account_form[:last_name]
		u.email = account_form[:email]
		u.password = account_form[:password]
		u.password_confirmation = account_form[:password_confirmation]
		u.email_confirmation = true
		u.role = account_form[:role]
	end

    redirect url :account_list, :index
  end
end
