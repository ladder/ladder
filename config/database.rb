# Connection.new takes host, port
host = ENV['MONGOLAB_URI'] || 'localhost'
port = Mongo::Connection::DEFAULT_PORT

database_name = case Padrino.env
  when :development then 'ladder_development'
  when :production  then 'ladder_production'
  when :staging     then 'ladder_staging'
  when :test        then 'ladder_test'
end

Mongoid.database = Mongo::Connection.new(
  host,
  port,
  {:pool_size => Parallel.physical_processor_count}
).db(database_name)

Mongoid.max_retries_on_connection_failure = 2