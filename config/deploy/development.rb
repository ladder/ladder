#If we're not deploying to production, assume we're deploying to a local Vagrant
# box for testing our deployment scripts.  In this case, the default ssh port is
# 2222
set :ssh_options, { :forward_agent => true,
                    :port => 2222,
                    :keys => [File.join(ENV["HOME"], ".ssh", "ladder_rsa")]
}


role :web, "localhost"
role :app, "localhost"
role :db,  "localhost", :primary => true 
set :server, "localhost"
