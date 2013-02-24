set_default :ruby_version, "1.9.3-p385"
set_default :yaml_version, "0.1.4"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    sudo "sudo apt-get -y install git-core build-essential zlib1g-dev libssl-dev libtool libyaml-dev libxslt-dev libxml2-dev libreadline5-dev"

    run "[ -d 'yaml-#{yaml_version}' ] || wget http://pyyaml.org/download/libyaml/yaml-#{yaml_version}.tar.gz"
    run "[ -d 'yaml-#{yaml_version}' ] || tar xvf yaml-#{yaml_version}.tar.gz"
    run "cd ~/yaml-#{yaml_version} && ./configure --prefix=/usr/local"
    run "cd ~/yaml-#{yaml_version} && make && #{sudo} make install"
    run "cd ~/yaml-#{yaml_version} && #{sudo} make install"

    run "[ -d '.rbenv' ] || git clone git://github.com/sstephenson/rbenv.git .rbenv"

    run "[ -d 'ruby-#{ruby_version}' ] || wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ruby_version}.tar.gz"
    run "[ -d 'ruby-#{ruby_version}' ] || tar -xvf ruby-#{ruby_version}.tar.gz"
    run "cd ruby-#{ruby_version} && ./configure --prefix=$HOME/.rbenv/versions/#{ruby_version} && make && make install"

    run %q{echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"' >> ~/.profile}
    run %q{echo 'eval "$(rbenv init -)"' >> ~/.profile}
    run %q{echo 'export RAILS_ENV=production' >> ~/.profile}
    run %q{echo 'export RACK_ENV=production' >> ~/.profile}

    run %q{export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"}
    run %q{eval "$(rbenv init -)"}
    run %q{export RAILS_ENV=production}
    run %q{export RACK_ENV=production}

    run "rbenv global #{ruby_version}"
    sleep(1)
    run "gem update --system"
    run "gem install bundler --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "rbenv:install"
end
