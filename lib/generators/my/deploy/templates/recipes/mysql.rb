set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL Password: " }

namespace :mysql do

  desc "Create mysql db - cap deploy:mysql:create_db"
  task :create_db, roles: :db do
    run "mysqladmin -u root -p#{mysql_password} create #{application}_production"
  end

end
