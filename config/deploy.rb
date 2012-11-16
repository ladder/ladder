#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'
require 'bundler/capistrano'

set :rvm_ruby_string, '1.9.3-p286'
set :rvm_type, :user

set :application, "ladder"
set :repository,  "git@ministryofcomputation.com:ladder.git"

set :scm, :git

set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

default_run_options[:pty] = true

set :user, "ladder"
set :group, user
set :runner, user

set :host, "#{user}@mytpl.ca"
role :web, host
role :app, host

set :rack_env, :production

set :deploy_to, "/srv/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

namespace :deploy do

  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
  end

  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
  end

  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

end
