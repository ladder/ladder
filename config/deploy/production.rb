set :ssh_options, { :forward_agent => true,
                    :keys => [File.join(ENV["HOME"], ".ssh", "github_rsa")]
}

role :web, "ladder.deliberatedata.com"
role :app, "ladder.deliberatedata.com"
role :db,  "ladder.deliberatedata.com", :primary => true

set :server, "ladder.deliberatedata.com"
set :nginx_server_name, "ladder.deliberatedata.com"

set :unicorn_env, "production"
set :rails_env, "production" # For Sidekiq Rails-centric-ness of their cap task

set :unicorn_workers, 2
set :sidekiq_processes, 2