namespace :unicorn do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task "#{command}", roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  desc "Setup unicorn configuration for this application"
  task :setup, roles: :app do
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
  end

  desc "Autostart unicorn"
  task :autostart, roles: :app do
    sudo "update-rc.d unicorn_#{application} defaults"
  end

  after "deploy:cold", "unicorn:setup"
  after "unicorn:setup", "unicorn:autostart"
  after "unicorn:autostart", "unicorn:start"
end
