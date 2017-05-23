Svipk::Dashboard.controllers :survey do
  before do

    @survey = Survey.where(account_id: @user.id, index: params[:survey_index]).first
    populate_survey_urls(@survey)
    @themes = Theme.all
    redirect url :survey_list, :index if @survey.nil?
  end

  get :index, map: '/survey/:survey_index', :provides => [:json, :html] do
    case content_type
      when :json
        return {
            ID: @survey.id,
            Name: @survey.name,
            AutoReset: @survey.auto_reset,
            AutoResetInterval: @survey.auto_reset_interval,
            RedirectUrl: @survey.redirect_url,
            Questions: @survey.questions
        }.to_json
      when :html
              if @survey.status == 'draft'
                redirect url :survey, :edit, survey_index: @survey.index
              else
                redirect url :survey, :result, survey_index: @survey.index
              end
    end
  end
  get :delete, map: '/survey/:survey_index/delete' do

    # Get all question that have index larger than current question
    above_surveys = @user.surveys
    above_surveys.sort! { |a, b| a.index<=> b.index }

    # Reposition by subtract each question index by 1
    above_surveys.each do |survey|
      if (survey.index > @survey.index)
        survey.index -= 1
        survey.save
      end
    end
    delete_survey(@survey)
    # Return to question list after done
    # TODO render question list if request is ajax
    redirect url :survey_list, :index
  end

  get :edit, map: '/survey/:survey_index/edit' do
    render 'survey/edit'
  end
  get :clone, map: '/survey/:survey_index/clone' do
    @survey.clone

    redirect url :survey_list, :index
  end
  get :start_over, map: '/survey/:survey_index/start_over' do
    start_over_survey(@survey)
    redirect url :survey_list, :index
  end

  get :stop, map: '/survey/:survey_index/stop' do
    @survey.status = 'finished'
    @survey.finished_at = Time.now
    @survey.save
    redirect url :survey_list, :index
  end
  get :enable, map: '/survey/:survey_index/enable' do
    @survey.status = 'active'
    @survey.save
    redirect url :survey_list, :index
  end
  post :edit, map: '/survey/:survey_index/edit' do
    survey_form = params[:survey] # TODO validation here
    custom_url = survey_form[:custom_url]
    if custom_url.nil? || custom_url.strip.length == 0
      custom_url = nil
    end
    begin
      @survey.name = survey_form[:name]
      @survey.theme_id = survey_form[:theme]
      @survey.custom_url = custom_url
      @survey.auto_reset = survey_form[:autoRepeat].nil? ? 0 : 1
      @survey.auto_reset_interval = survey_form[:autoRepeatInterval]
      @survey.redirect_url = survey_form[:redirectUrl]
      t = @survey.survey_translations.first
      t.description = survey_form[:description]
      t.save
      @survey.save
      redirect url :survey, :questions, survey_index: @survey.index
    rescue
      flash[:error] = "This custom url has been choosen. Please pick another one"
      redirect url :survey, :edit
      return
    end
  end
  get :questions, map: '/survey/:survey_index/questions', :provides => [:json, :html] do
    @question_types = QuestionType.where(:active => true)
    questions = @survey.questions
    questions.sort! { |a, b| a.index<=> b.index }.select{|a| a.valid?}
    @hash_choices = Hash.new
    for question in questions
      choices = Array.new
      options = question.options
      if question.question_type_id == QuestionType::MULTIPLE_CHOICES
        for option in options
          choices = choices.push(option.option_translations.first.content)
        end

      end
    end
    case content_type
      when :json
        return questions.map{|q| {
            :questionId => q.id,
            :questionIndex => q.index,
            :questionText => q.questionText,
            :questionTypeId => q.question_type_id,
            :multipleSelection => q.question_type_id == QuestionType::MULTIPLE_CHOICES ? q.actual.multiple_selection : '',
            :options => q.question_type_id == 2 ? q.options.map {|op| op.optionText}.join(",") : ""
        }}.to_json
      else
        render 'survey/questions'
    end
  end

  post :new_question, map: '/survey/:survey_index/new-question' do
    form = params[:question] #TODO validation
    result = create_question(form)
    redirect url :survey, :questions, survey_index: @survey.index
  end

  post :updateOrder, map: '/survey/:survey_index/updateOrder', :provides => [:json] do
    updatedQuestionOrderRequest = Oj.load(request.body.read)
    if (updatedQuestionOrderRequest)
      currentIndex = updatedQuestionOrderRequest['currentIndex']
      targetIndex = updatedQuestionOrderRequest['targetIndex']
      #Get moving question
      movingQuestion = @survey.questions.select{|q| q.index == currentIndex}.first
      if (movingQuestion)
        if (currentIndex > targetIndex)
          #Move all questions from targetIndex to currentIndex down 1 unit
          affected_questions = @survey.questions.select{|q| q.index >= targetIndex && q.index < currentIndex}
          DB.transaction do
            affected_questions.each do |q|
              q.index += 1
              q.save
            end
            movingQuestion.index = targetIndex
            movingQuestion.save
          end
        else
          #Move all questions from currentIndex targetIndex up 1 unit
          affected_questions = @survey.questions.select { |q| q.index <= targetIndex && q.index > currentIndex }
          DB.transaction do
            affected_questions.each do |q|
              q.index -= 1
              q.save
            end
            movingQuestion.index = targetIndex
            movingQuestion.save
          end
        end
      end
      return {status: 1, message: "Success"}.to_json
    end
  end
  get :result, map: '/survey/:survey_index/result' do
    # @feedbacks = @survey.feedbacks
    @questions = @survey.questions.sort! { |a, b| a.index <=> b.index }.select {|q| q.question_type_id != QuestionType::INFO}
    @active_page = :result
    render 'survey/result'
  end

  get :publish, map: '/survey/:survey_index/publish' do
    @survey.status = "active"
    @survey.save
    render 'survey/publish'

  end
  get :info, map: '/survey/:survey_index/info' do
    @survey.status = "active"
    @survey.save
    render 'survey/info'
  end
  get :feedbacks, map: '/survey/:survey_index/feedbacks', :provides => [:pdf, :xlsx, :csv, :html] do
    @feedbacks = @survey.feedbacks.sort! { |a, b| a.created_at <=> b.created_at }.reverse #.take(20)
    @active_page = :feedbacks
    case content_type
      when :pdf then
        html = render "export.pdf", :layout => 'exportPdf.erb'
        kit = PDFKit.new(html, :page_size => 'Letter')
        kit.stylesheets << 'C:\Padrino\svipk\app\assets\stylesheets\exportToPdf.css'
        return kit.to_pdf
      when :csv then
        questionContents = []
        @survey.questions.each do |q|
          questionContents << q.questionText
        end
        questionContents.insert(0, "Time stamp");
        return CSV.generate do |csv|
          csv << questionContents
          @feedbacks.each do |fb|
            row = [fb.created_at]
            fb.parsed_answers.each do |answer|
              row << answer
            end
            csv << row
          end
        end
      when :xlsx then
        questionContents = []
        @survey.questions.each do |q|
          questionContents << q.questionText
        end
        questionContents.insert(0, "Time stamp");
        p = Axlsx::Package.new
        p.workbook.add_worksheet(:name => "Answers") do |sheet|
          sheet.add_row questionContents
          @feedbacks.each do |fb|
            row = [fb.created_at]
            fb.parsed_answers.each do |answer|
              row << answer
            end
            sheet.add_row row
          end
        end
        temp = Tempfile.new("posts.xlsx")
        p.serialize temp
        send_file temp.path, :filename => "survey_answers.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
      else
        render 'survey/feedbacks'
    end
    render 'survey/feedbacks'
  end
end
