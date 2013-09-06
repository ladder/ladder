class Viewer < Padrino::Application
  register Padrino::Rendering
  register Padrino::Helpers
  register Kaminari::Helpers::SinatraHelpers

  configure :development do
    disable :asset_stamp

    use BetterErrors::Middleware
    BetterErrors.application_root = PADRINO_ROOT
  end

  configure :production do
    register Padrino::Cache
    register Padrino::Contrib::ExceptionNotifier
    register Padrino::Mailer

    # FIXME: search results will cache
#    enable :caching
    disable :raise_errors
    disable :show_exceptions

    set :exceptions_from,    "errors@deliberatedata.com"
    set :exceptions_to,      "errors@deliberatedata.com"
    set :exceptions_page,    'errors/50x'
    set :exceptions_layout,  :application
    set :delivery_method, :smtp => {
      :address              => "smtp.sendgrid.net",
      :port                 => 587,
      :authentication       => :plain,
      :user_name            => ENV['SENDGRID_USERNAME'],
      :password             => ENV['SENDGRID_PASSWORD'],
      :domain               => 'heroku.com',
      :enable_starttls_auto => true
    }
  end

  use Rack::Mongoid::Middleware::IdentityMap

  Mongoid::History.tracker_class_name = :history_tracker

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  error 404 do
    render('errors/40x', :layout => :application)
  end
end
