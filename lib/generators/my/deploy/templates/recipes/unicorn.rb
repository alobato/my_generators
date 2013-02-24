namespace :unicorn do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task "#{command}_unicorn", roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  desc "Setup unicorn configuration for this application"
  task :setup, roles: :app do
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
  end
  after "deploy:setup", "unicorn:setup"

  desc "Autostart unicorn"
  task :autostart_unicorn, roles: :app do
    sudo "update-rc.d unicorn_#{application} defaults"
  end
end
