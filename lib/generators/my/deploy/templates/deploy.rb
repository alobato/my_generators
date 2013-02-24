require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/rbenv"
load "config/recipes/nginx"
load "config/recipes/mysql"
load "config/recipes/nodejs"
load "config/recipes/check"
load "config/recipes/unicorn"

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
  "RACK_ENV": "production",
  "RAILS_ENV": "production",
  "PATH": "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
}

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  desc "Load schema"
  task :load_schema, roles: :app do
    rails_env = fetch(:rails_env, "production")
    run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} db:schema:load"
  end

  desc "Cold deploy"
  task :cold do # Overriding the default deploy:cold (http://stackoverflow.com/questions/1329778/dbschemaload-vs-dbmigrate-with-capistrano)
    update
    # load_schema
    migrate
    start_unicorn
    autostart_unicorn
    restart_nginx
  end

  task :setup_config, roles: :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    # put File.read("config/config.example.yml"), "#{shared_path}/config/config.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    # run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
end
