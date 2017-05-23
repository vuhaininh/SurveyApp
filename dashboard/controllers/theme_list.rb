Svipk::Dashboard.controllers :theme_list do

  before do
    @language_code = language.language_code
  end

  get :index, map: '/themes' do
    @themes = Theme.all
    @theme_types_with_translation = ThemeType.all.select { |item| item.theme_type_translations.any? }
    @theme_types = @theme_types_with_translation.map { |item|
      [
          item.theme_type_id,
          item.theme_type_translations.first.theme_type_description
      ]
    }
    render 'theme_list/index'
  end

  post :new_theme, map: '/new-theme' do
    theme_form = params[:theme]
    Theme.create do |t|
      t.name = theme_form[:name]
      t.created_by = current_user
      t.theme_type_id = theme_form[:type]
    end
    redirect url :theme_list, :index
  end

  post :new_theme_type, map: '/new-theme-type' do
    theme_type_form = params[:theme_type]
    theme_type = ThemeType.create do |t|
      t.available_for_all = theme_type_form[:available_for_all]
    end
    ThemeTypeTranslation.create do |t|
      t.theme_type_id = theme_type.theme_type_id
      t.theme_type_description = theme_type_form[:theme_type_description]
      t.language_code = language.language_code
    end
    redirect url :theme_list, :index
  end

  get :assign_user, :map => 'themes/:id/assign' do
    @theme = Theme.find(:id => params[:id])
    @account_themes = AccountTheme.where(:theme_id => params[:id])
    @emails = Account.map { |a| a.email }
    render 'theme_list/assign_user'
  end
  post :assign_user, :map => 'themes/:id/assign' do
    @theme = Theme.find(:id => params[:id])
    account_theme_form = params[:account_theme]
    @emails = account_theme_form[:emails]
    for email in @emails
      assigned_user = Account.find(:email => email)
      if assigned_user
        AccountTheme.create do |at|
          at.account = assigned_user
          at.theme = @theme
          at.activate_date = account_theme_form[:activate_date]
          at.expire_date = account_theme_form[:expire_date]
        end
      end
    end
    redirect url :theme_list, :assign_user, id: params[:id]
  end
  post :edit_assign_user, :map=> 'themes/edit_assignment' do
    account_theme_form = params[:account_theme]
    if account_theme_form[:account_id] && account_theme_form[:theme_id]
      at = AccountTheme.find(:account_id => account_theme_form[:account_id], :theme_id => account_theme_form[:theme_id])
      if at
        at.activate_date = account_theme_form[:activate_date]
        at.expire_date = account_theme_form[:expire_date]
        at.save
      end
    end

    redirect url :theme_list, :assign_user, id: account_theme_form[:theme_id]
  end

  post :unassign_user, :csrf_protection => false, :map => 'themes/:id/unassign' do
    @theme = Theme.find(:id => params[:id])
    user_ids = params[:user_ids]
    for user_id in user_ids
      account_theme = AccountTheme.find(:theme_id => @theme.id, :account_id => user_id)
      account_theme.delete
    end
  end

  post :delete_theme, :csrf_protection => false, :map => 'themes/:id/delete' do
    #Get theme
    theme_id = params[:id]
    theme = Theme.find(:id => theme_id)
    account_themes = AccountTheme.where(:theme_id => theme_id)
    surveys_using_this_theme = Survey.where(:theme_id => theme_id)
    if account_themes.count() > 0 || surveys_using_this_theme.count() > 0 then
      flash[:error] = "Theme can not be deleted because it is assigned to some users or has been used to create some surveys. You can disable theme instead"
    else
      theme.delete
      flash[:success] = "Theme is deleted successfully"
    end
    #redirect url :theme_list, :index
  end

  post :disable_theme, :map => 'themes/:id/disable_theme' do

  end

  post :edit_theme, :map => 'themes/edit_theme' do
    theme = params[:theme]
    target_theme = Theme.find(:id => theme[:id])
    if target_theme
      target_theme.name = theme[:name]
      target_theme.theme_type_id = theme[:type]
      target_theme.active = theme[:status]
      target_theme.save
    end
    redirect url :theme_list, :index
  end

  post :remove_user_from_theme, :map => 'themes/:theme_id/unassign_user/:user_id' do

  end

  get :item, :map => 'themes/:id' do

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
