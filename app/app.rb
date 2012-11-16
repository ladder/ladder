class Ladder < Padrino::Application

  register Padrino::Rendering
  register Padrino::Helpers
  register Kaminari::Helpers::SinatraHelpers

  use Rack::Mongoid::Middleware::IdentityMap

  enable :sessions
  disable :show_exceptions

  error Mongoid::Errors::DocumentNotFound do
    halt 404
  end

  error 404 do
    render('errors/40x', :layout => :application)
  end

  error 500 do
    render('errors/50x', :layout => :application)
  end

end