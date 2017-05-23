module Svipk
  class App < Padrino::Application
    if Padrino.env == :development
      disable :raise_errors
      disable :show_exceptions
    end
    register Padrino::Mailer
      set :delivery_method, :smtp => {
          :address              => "smtp.gmail.com",
          :port                 => 587,
          :user_name            => 'surveyinpocket@gmail.com',
          :password             => 'NinhNamHoang1989',
          :authentication       => :plain,
          :enable_starttls_auto => true
      }
    register Padrino::Helpers
    register Padrino::Flash
    register Padrino::Cookies
    register CompassInitializer
    register Padrino::Sprockets
    register Padrino::Contrib::ExceptionNotifier
      set :exceptions_from,    "surveyinpocket@gmail.com"
      set :exceptions_to,      "nguyentiendat05@gmail.com; haininh.vu89@gmail.com; harryle.fi@gmail.com"
      set :exceptions_subject, ENV['EXCEPTION_PREFIX']

    sprockets :minify => (Padrino.env == :production)
    enable :sessions
    get :ois, map: '/:smug' do
      survey = nil
      if params[:smug]
        survey = Survey.first(Sequel.function(:lower, :custom_url) => params[:smug].downcase)
      end
      if(survey)
        id = OID.encode(survey.id);
        redirect Frontend.url(:feedback, :index, :id => id)
      else
        redirect "/"
      end
    end
    get :index, map: '/' do
      redirect "/dashboard/login"
    end
    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache.new(:LRUHash) # Keeps cached values in memory
    # set :cache, Padrino::Cache.new(:Memcached) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Memcached, '127.0.0.1:11211', :exception_retry_limit => 1)
    # set :cache, Padrino::Cache.new(:Memcached, :backend => memcached_or_dalli_instance)
    # set :cache, Padrino::Cache.new(:Redis) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Redis, :host => '127.0.0.1', :port => 6379, :db => 0)
    # set :cache, Padrino::Cache.new(:Redis, :backend => redis_instance)
    # set :cache, Padrino::Cache.new(:Mongo) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Mongo, :backend => mongo_client_instance)
    # set :cache, Padrino::Cache.new(:File, :dir => Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 500 do
    #     render 'errors/500'
    #   end
    #
  end
end
