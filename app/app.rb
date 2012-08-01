class Ladder < Padrino::Application

  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Kaminari::Helpers::SinatraHelpers

  enable :sessions

end
