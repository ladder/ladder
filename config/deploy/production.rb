set :ssh_options, { :forward_agent => true,
                    :keys => [File.join(ENV["HOME"], ".ssh", "github_rsa")]
}

role :web, "ladder.deliberatedata.com"
role :app, "ladder.deliberatedata.com"
role :db,  "ladder.deliberatedata.com", :primary => true
set :server, "ladder.deliberatedata.com"

set :unicorn_env, "production"
