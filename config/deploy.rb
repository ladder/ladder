require 'bundler/capistrano'
set :application, "ladder"
set :repository,  "git@github.com:mjsuhonos/ladder.git"

set :scm, :git 
set :branch, ENV['BRANCH'] || 'master'

set :ssh_options, { :forward_agent => true }
#set :user, "deployer"  # The server's user for deploys
#set :scm_passphrase, "p@ssw0rd"  # The deploy user's password
set :deploy_via, :remote_cache

set :user, 'deploy'
set :deploy_to, "/home/deploy"

default_run_options[:pty] = true
set :use_sudo, true 

set :default_environment, {
  'PATH' => "/opt/rbenv/shims/:$PATH"
}
set :stages, %w(production development)
set :default_stage, "development"
require 'capistrano/ext/multistage'

set :nginx_server_name, "ladder.deliberatedata.com
set :unicorn_workers, 4
require 'capistrano-nginx-unicorn'

require 'sidekiq/capistrano'
