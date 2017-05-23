Svipk::Dashboard.controllers :upload do

  post :new_file, map: '/new-file' do

	@categories = @user.categories
	@selected = @categories.first.id
    upload = Upload.create do |u|
      u.file = params[:file]
	  u.category_id = @selected
    end
	redirect url :category,:index 
  end

  post :uploadOptionImage, map: '/uploadOptionImage' do
    optionUploader = OptionUploader.new
    cacheFile = optionUploader.cache!(params[:file])
    return optionUploader.cache_name
  end
end
