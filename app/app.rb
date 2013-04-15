class Ladder < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl
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

    enable :caching
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

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  error 404 do
    render('errors/40x', :layout => :application)
  end
=begin
  set :admin_model, 'Account'
  set :login_page, "/admin/sessions/new"
  enable :store_location
  set :session_id, "my_shared_session_id"

  access_control.roles_for :any do |role|
    role.protect '/'
  end

  access_control.roles_for :admin do |role|
    role.project_module :accounts, '/accounts'
  end
=end
end
