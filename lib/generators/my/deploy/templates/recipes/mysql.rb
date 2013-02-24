set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL Password: " }

namespace :mysql do
  desc "Install MySQL with apt-get"
  task :install, roles: :db do
    sudo %q{debconf-set-selections <<< "mysql-server-5.1 mysql-server/root_password password #{mysql_password}"}
    sudo %q{debconf-set-selections <<< "mysql-server-5.1 mysql-server/root_password_again password #{mysql_password}"}
    sudo "apt-get -y install mysql-server mysql-client libmysqlclient-dev"
  end
  after "deploy:install", "mysql:install"

  desc "Create mysql db - cap deploy:mysql:create_db -s pass=secret"
  task :create_db, roles: :db do
    run "mysqladmin -u root -p#{pass} create #{application}_production"
  end

end
