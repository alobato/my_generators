# def template(from, to)
#   erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
#   put ERB.new(erb).result(binding), to
# end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    sudo "apt-get -y update"
    sudo "locale-gen pt_BR pt_BR.UTF-8"
    sudo "dpkg-reconfigure locales"
    sudo "ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime"
    sudo "apt-get -y install python-software-properties sudo curl wget git-core"
  end
end
