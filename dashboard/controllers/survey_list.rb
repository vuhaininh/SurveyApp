Svipk::Dashboard.controllers :survey_list do
  get :index, map: '/' do
    @active_surveys = @user.active_surveys.sort! { |a, b| a.index<=> b.index }
    @draft_surveys = @user.draft_surveys.sort! { |a, b| a.index<=> b.index }
    @finished_surveys = @user.finished_surveys.sort! { |a, b| a.index<=> b.index }
    @active_page = :index

    render 'survey_list/index'
  end

  get :active, map: '/active' do
    @active_surveys = @user.active_surveys
    @active_page = :active
    render 'survey_list/active'
  end

  get :draft, map: '/draft' do
    @draft_surveys = @user.draft_surveys
    @active_page = :draft
    render 'survey_list/draft'
  end

  get :finished, map: '/finished' do
    @finished_surveys = @user.finished_surveys
    @active_page = :finish
    render 'survey_list/finished'
  end

  get :new, map: '/new-survey' do
    @survey = Survey.new
    @themes = Theme.all.select { |item| (item.theme_type.available_for_all || item.assigned_users.any? { |u| u.id == @user.id }) && item.active }
    render 'survey_list/create'
  end

  post :new, map: '/new-survey' do
    survey_form = params[:survey] # TODO: validation
    custom_url = survey_form[:custom_url]
    if custom_url.nil? || custom_url.strip.length == 0
      custom_url = nil
    end
    if (is_url_exist(survey_form[:custom_url]))
      flash[:error] = "This custom url has been choosen. Please pick another one"
      redirect url :survey_list, :new
    else
      begin
        @survey = Survey.new
        @survey.account = @user
        @survey.theme_id = survey_form[:theme]
        @survey.index = @user.surveys.count + 1
        @survey.name = survey_form[:name]
        @survey.status = 'draft'
        @survey.custom_url = custom_url
        @survey.auto_reset = survey_form[:autoRepeat] == "on" ? 1 : 0
        @survey.auto_reset_interval = survey_form[:autoRepeatInterval]
        @survey.full_screen = survey_form[:fullScreenOnOpen]? 1 : 0
        @survey.redirect_url = survey_form[:redirectUrl]

        if(@survey.valid?)
          @survey.save
          @survey_translation = SurveyTranslation.create do |t|
            t.survey = @survey
            t.description = survey_form[:description]
          end
        else
          flash[:error] = @survey.errors
          return redirect url :survey_list, :new
        end
      rescue Exception => e
        flash[:error] = e.message
      end
    end
    redirect url :survey, :questions, survey_index: @survey.index
  end

  post :check_custom_url, map: '/check_custom_url' do
    object = JSON.parse(request.body.read)
    custom_url = object["url"]
    if (custom_url && custom_url.strip.downcase.length > 0)
      survey_index = object["survey_index"];
      if (survey_index)
        survey = Survey.where(account_id: @user.id, index: survey_index).first
        if (survey && survey.custom_url && survey.custom_url.strip.downcase == custom_url.strip.downcase)
          return true.to_json
        end
      end
      return (!is_url_exist(custom_url)).to_json
    end
    return true.to_json
  end
end
