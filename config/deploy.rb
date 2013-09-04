require 'bundler/capistrano'
set :application, "ladder"
set :repository,  "git@github.com:mjsuhonos/ladder.git"

set :scm, :git 
set :branch, "master"
set :ssh_options, { :forward_agent => true }
set :user, "deployer"  # The server's user for deploys
set :scm_passphrase, "p@ssw0rd"  # The deploy user's password
set :deploy_via, :remote_cache
set :deploy_to, "/home/deploy"

set :default_environment, {
  'PATH' => "/opt/rbenv/shims/:$PATH"
}
set :stages, %w(production development)
set :default_stage, "development"
require 'capistrano/ext/multistage'
