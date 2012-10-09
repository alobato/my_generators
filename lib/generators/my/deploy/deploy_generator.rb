require 'generators/my'

module My
  module Generators
    class DeployGenerator < Base
      argument :app_name, :type => :string, :default => '', :banner => 'app_name'
      argument :server_ip, :type => :string, :default => '', :banner => 'server_ip'
      argument :domain, :type => :string, :default => '', :banner => 'domain'

      def add_gems
        add_gem 'capistrano', '2.13.4'
        add_gem 'unicorn', '4.3.1'
        add_gem 'net-ssh', '2.6.0'
        add_gem 'mysql2', '0.3.11'
      end

      def create_deploy
        copy_file "Capfile", "Capfile"
        template "deploy.rb", "config/deploy.rb"
        template "unicorn.rb", "config/unicorn.rb"
        template "unicorn_init.sh", "config/unicorn_init.sh"
        template "nginx.conf", "config/nginx.conf"
      end

      private

      def destination_path(path)
        File.join(destination_root, path)
      end

    end
  end
end
