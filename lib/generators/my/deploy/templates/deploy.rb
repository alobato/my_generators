require "bundler/capistrano"

server "<%= server_ip %>", :web, :app, :db, primary: true

set :application, "<%= app_name %>"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:alobato/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :default_environment, {
  'RACK_ENV' => 'production',
  'RAILS_ENV' => 'production',
  'PATH' => "/home/deployer/.rbenv/shims:/home/deployer/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
}

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do

  desc "Restart Nginx server"
  task :restart_nginx, roles: :app do
    sudo "service nginx restart"
  end

  desc "Create mysql db - cap deploy:create_mysql_db -s pass=secret"
  task :create_mysql_db, roles: :db do
    run "mysqladmin -u root -p#{pass} create #{application}_production"
  end

  desc "Remove nginx default site"
  task :remove_nginx_default_site, roles: :app do
    sudo "rm -f /etc/nginx/sites-enabled/default"
  end

  desc "Autostart unicorn"
  task :autostart_unicorn, roles: :app do
    sudo "update-rc.d unicorn_#{application} defaults"
  end

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
    start
    remove_nginx_default_site
    autostart_unicorn
    restart_nginx
  end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    # put File.read("config/config.example.yml"), "#{shared_path}/config/config.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      # puts "WARNING: HEAD is not the same as origin/master"
      # puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
