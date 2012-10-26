class Ladder < Padrino::Application

  register Padrino::Rendering
  register Padrino::Helpers
  register Kaminari::Helpers::SinatraHelpers

#  use Rack::Mongoid::Middleware::IdentityMap

  enable :sessions

end