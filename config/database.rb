# Connection.new takes host, port
host = ENV['MONGOLAB_URI'] || 'localhost'
port = Mongo::Connection::DEFAULT_PORT

database_name = case Padrino.env
  when :development then 'ladder_development'
  when :production  then 'ladder_production'
  when :staging     then 'ladder_staging'
  when :test        then 'ladder_test'
end

Mongoid::Config.sessions = {default: {hosts: ["#{host}:#{port}"], database: database_name}}

# @see: http://mongoid.org/en/mongoid/docs/installation.html#configuration
#Mongoid::Config.options  = {identity_map_enabled: true}

#Mongoid.logger = Padrino.logger
#Moped.logger = Padrino.logger
