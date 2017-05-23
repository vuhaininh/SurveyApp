Svipk::Dashboard.controllers :session do
  
  #Login page
  get :login, map: '/login' do
    render 'session/login', :layout => :login
  end
  
  #Login
  post :login, map: '/login' do
    user_form = params[:user]
	user = Account.authenticate(user_form[:email],user_form[:password])
	
    if !user.nil?
      sign_in user
      redirect url :survey_list, :index
    else
      render 'session/login-error', :layout => :login
    end
  end
   get :logout, map: '/logout' do
		sign_out if signed_in?
		redirect url :session, :login
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
