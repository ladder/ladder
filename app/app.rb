class Ladder < Padrino::Application
  register Padrino::Rendering
  register Padrino::Helpers
#  register Kaminari::Helpers::SinatraHelpers

  configure do
    mime_type :marc, ['application/marc', 'application/marc+xml', 'application/marc+json']
    mime_type :mods, 'application/mods+xml'
  end

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

  Mongoid::History.tracker_class_name = :history_tracker

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end
=begin
  error 404 do
    render('errors/40x', :layout => :application)
  end
=end
  before do
    # check API key
    tenant = Tenant.with(:database => :ladder).find_by(:api_key => params[:api_key]) rescue nil

    halt 401, {:ok => false, :status => 401}.to_json unless tenant

    # switch Mongoid to tenant's database
    Mongoid::Config.override_database("ladder_#{tenant.database}")
  end

=begin
  set :admin_model, 'Account'
  set :login_page, "/admin/sessions/new"
  enable :store_location
  set :session_id, "my_shared_session_id"
  before do
    # check API key
    tenant = Tenant.with(:database => :ladder).find_by(:api_key => params[:api_key]) rescue nil

    halt 401, {:ok => false, :status => 401}.to_json unless tenant

    # switch Mongoid to tenant's database
    Mongoid::Config.override_database("ladder_#{tenant.database}")
  end

  access_control.roles_for :admin do |role|
    role.project_module :accounts, '/accounts'
  end
=end
end
