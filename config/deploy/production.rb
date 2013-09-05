set :ssh_options, { :forward_agent => true,
                    :keys => [File.join(ENV["HOME"], ".ssh", "deflectadmin_rsa")]
}

role :web, "gameimprovement.com"
role :app, "gameimprovement.com"
role :db,  "gameimprovement.com", :primary => true 
set :server, "gameimprovement.com"
set :unicorn_env, "production"
