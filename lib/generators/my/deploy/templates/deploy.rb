require "bundler/capistrano"

load "config/recipes/nginx"
load "config/recipes/check"
load "config/recipes/unicorn"
load "config/recipes/mysql"

server "<%= server_ip %>", :web, :app, :db, primary: true
ssh_options[:port] = 888

set :user, "deployer"
set :application, "<%= app_name %>"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository,  "git@bitbucket.org:alobato/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :default_environment, {
  "RACK_ENV" => "production",
  "RAILS_ENV" => "production",
  "PATH" => "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
}

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do

  task :setup_config, roles: :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/config.example.yml"), "#{shared_path}/config/config.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
end
