class Ladder < Padrino::Application

  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
#  register Padrino::Responders

  register Padrino::Contrib::ExceptionNotifier
  register Kaminari::Helpers::SinatraHelpers

  configure :development do
    disable :asset_stamp
  end

  configure :production do
    disable :raise_errors
    disable :show_exceptions

    set :exceptions_from,    "errors@mytpl.ca"
    set :exceptions_to,      "errors@deliberatedata.com"
    set :exceptions_page,    'errors/50x'
    set :exceptions_layout,  :application
  end

  use Rack::Mongoid::Middleware::IdentityMap

  enable :sessions

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  error 404 do
    render('errors/40x', :layout => :application)
  end

end