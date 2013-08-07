# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  config.vm.hostname = "ladder-berkshelf"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # path to private SSH key
  config.ssh.private_key_path = '~/.ssh/github_rsa'

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080    # Nginx/Unicorn
  config.vm.network :forwarded_port, guest: 9200, host: 9200  # ElasticSearch

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  
  # Example for Digital Ocean:
  config.vm.provider :digital_ocean do |provider|
    provider.client_id = '31bzQvLzYxthvkjOLyv2g'
    provider.api_key = 'gl2ovOorqeBjsBywMW7pYlyt7uPS7Ca3rz7x1yTqV'
    provider.image = 'Ubuntu 12.04 x64'
  end

  # Example for VirtualBox:
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # Ensure we are using the latest version of Chef on the VM
  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
        'recipe[elasticsearch]',
        'recipe[mongodb-10gen::single]',
        'recipe[redisio::install]',
        'recipe[redisio::enable]',
    ]

    # TODO: refactor these out into a default recipe

#    chef.add_recipe "ruby_build"
#    chef.add_recipe "rbenv"
#    chef.add_recipe "rbenv::system"

#    chef.add_recipe "redis::source"

  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  end

end
