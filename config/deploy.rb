set :application, "ladder"
set :repository,  "git@github.com:mjsuhonos/ladder.git"

set :scm, :git 
set :branch, "master"
set :ssh_options, { :forward_agent => true }
set :user, "deployer"  # The server's user for deploys
set :scm_passphrase, "p@ssw0rd"  # The deploy user's password
set :deploy_via, :remote_cache

role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"
