# Enables support for Compass, a stylesheet authoring framework based on SASS.
# See http://compass-style.org/ for more details.
# Store Compass/SASS files (by default) within 'app/stylesheets'.

module CompassInitializer
  def self.registered(app)
    require 'sass/plugin/rack'

    Compass.configuration do |config|
      config.project_path = Padrino.root
      config.sass_dir = "app/assets/stylesheets"
      config.project_type = :stand_alone
      config.http_path = "/"
      config.css_dir = "app/assets/stylesheets"
      config.images_dir = "app/assets/images"
      config.javascripts_dir = "app/assets/javascripts"
      config.output_style = :compressed
    end

    Compass.configure_sass_plugin!
    Compass.handle_configuration_change!

    app.use Sass::Plugin::Rack
  end
end
