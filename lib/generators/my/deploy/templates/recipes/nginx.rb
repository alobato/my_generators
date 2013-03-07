namespace :nginx do
  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    sudo "rm -f /etc/nginx/sites-enabled/default"
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task "#{command}", roles: :web do
      sudo "service nginx #{command}"
    end
  end
end
