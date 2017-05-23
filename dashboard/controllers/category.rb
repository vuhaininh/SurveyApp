Svipk::Dashboard.controllers :category do
  
  get :index, map: '/categories' do
	@categories = @user.categories
	if @categories.first == nil
		Category.create do |c|
		  c.name = "Default"
		  c.account = @user
		end
	end
	@categories = @user.categories
	@selected = @categories.first.id
	@uploads = @categories.first.uploads
    render 'category/index'
  end
  
  post :new_category, map: '/categories/new' do
    category_form = params[:category]
    Category.create do |c|
      c.name = category_form[:name]
      c.account = @user
    end
    redirect url :category, :index
  end
  
  get :category, map: '/category/:category_id/' do
	@categories = @user.categories
	@selected = params[:category_id].to_i
    render 'category/index'
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
