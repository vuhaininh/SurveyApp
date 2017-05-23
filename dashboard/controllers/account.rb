Svipk::Dashboard.controllers :account do
   get :index, map: '/account-settings' do
    render 'account/index'
  end
  # ugly route, considering rename
  post :edit, map: '/account/:account_id/edit' do
    account_form = params[:account] # TODO: validation
	@user.first_name = account_form[:first_name]
	@user.last_name = account_form[:last_name]
	@user.password = account_form[:password]
	@user.password_confirmation = account_form[:password_confirmation]
	@user.save
	redirect url :account, :index
    # TODO deal with ajax call
  end 
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  

end
