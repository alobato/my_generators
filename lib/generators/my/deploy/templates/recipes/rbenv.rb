set_default :ruby_version, "1.9.3-p385"
set_default :yaml_version, "0.1.4"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    sudo "sudo apt-get -y install git-core build-essential zlib1g-dev libssl-dev libtool libyaml-dev libxslt-dev libxml2-dev libreadline5-dev"

    run "cd && wget http://pyyaml.org/download/libyaml/yaml-#{yaml_version}.tar.gz"
    run "tar zxvf yaml-#{yaml_version}.tar.gz"
    run "cd yaml-#{yaml_version}"
    run "./configure --prefix=/usr/local"
    run "make"
    sudo "make install"
    run "rm -rf ~/yaml-#{yaml_version}"

    run "cd && git clone git://github.com/sstephenson/rbenv.git .rbenv"

    run "cd && wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{ruby_version}.tar.gz"
    run "tar -xzvf ruby-#{ruby_version}.tar.gz"
    run "cd ruby-#{ruby_version}"
    run "./configure --prefix=$HOME/.rbenv/versions/#{ruby_version}"
    run "make"
    run "make install"
    run "rm -rf ~/ruby-#{ruby_version}"

    run %q{echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"' >> ~/.profile}
    run %q{echo 'eval "$(rbenv init -)"' >> ~/.profile}
    run %q{echo 'export RAILS_ENV=production' >> ~/.profile}
    run %q{echo 'export RACK_ENV=production' >> ~/.profile}
    run %q{source ~/.profile}
    run "rbenv global #{ruby_version}"
    sleep(1)
    run "gem update --system"
    run "gem install bundler --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "rbenv:install"
end
