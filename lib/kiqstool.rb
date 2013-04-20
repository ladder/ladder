module Kiqstool
  class Client
    def call(worker_class, msg, queue)
      msg['database'] = Search.index_name
      yield
    end
  end

  class Server
    def call(worker_instance, msg, queue)
      Mongoid::Config.override_database(msg['database']) if msg['database']
      yield
    end
  end
end