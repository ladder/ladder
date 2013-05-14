class Ladder < Padrino::Application
  register Padrino::Rendering
  register Padrino::Helpers

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

  def self.destroy
    # Remove existing Mongo DB
    Mongoid::Sessions.default.with(:database => Search.index_name).collections.each {|collection| collection.drop}

    # Remove existing ES index
    index_response = Search.delete

    # Send index/mapping
    self.create

    index_response
  end

  def self.create
    %w[Agent Concept Resource].each do |model|
      klass = model.classify.constantize
      klass.create_indexes
      klass.put_mapping
    end
  end
end