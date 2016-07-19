Vagrant.configure "2" do |config|
  vagrant_version = Vagrant::VERSION.sub /^v/, ""
  vagrant_dir = File.expand_path File.dirname(__FILE__)

  # VirtualBox configuration
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--cpus", 1]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
  # on your host machine inside the guest. See the manual for `ssh-add`.
  config.ssh.forward_agent = true

  # This box is provided by Ubuntu vagrantcloud.com and is a nicely sized (332MB)
  # box containing the Ubuntu 14.04 Trusty 64 bit release. Once this box is downloaded
  # to your host computer, it is cached for future use under the specified box name.
  config.vm.box = "themejuice/graft"
  config.vm.hostname = "graft"

  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may need to
  # enter a password for Vagrant to access your hosts file.
  #
  # By default, we'll include the domains set up by graft through the graft-hosts file
  # located in the www/ directory.
  #
  # Other domains can be automatically added by including a graft-hosts file containing
  # individual domains separated by whitespace in subdirectories of www/.
  if !defined? Landrush && defined? VagrantPlugins::HostsUpdater
    paths = Dir[File.join(vagrant_dir, "www", "**", "graft-hosts")]

    hosts = paths.map do |path|
      lines = File.readlines(path).map &:chomp
      lines.grep /\A[^#]/
    end.flatten.uniq

    config.hostsupdater.aliases = hosts
    config.hostsupdater.remove_on_suspend = true
  end

  # A private network is created by default. This is the IP address through which your
  # host machine will communicate to the guest. In this default configuration, the virtual
  # machine will have an IP address of 192.168.50.4 and a virtual network adapter will be
  # created on your host machine with the IP of 192.168.50.1 as a gateway.
  #
  # Access to the guest machine is only available to your local host. To provide access to
  # other devices, a public network should be configured or port forwarding enabled.
  #
  # Note: If your existing network is using the 192.168.50.x subnet, this default IP address
  # should be changed. If more than one VM is running through VirtualBox, including other
  # Vagrant machines, different subnets should be used for each.
  #
  config.vm.network :private_network, {
    :id => "graft_primary",
    :ip => "192.168.50.4"
  }

  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  config.vm.synced_folder "database/", "/srv/database"

  # If a server-conf directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is currently used to maintain various config files for php and
  # Apache as well as any pre-existing database files.
  config.vm.synced_folder "config/", "/srv/config"

  # If a log directory exists in the same directory as your Vagrantfile, a mapped
  # directory inside the VM will be created for some generated log files.
  config.vm.synced_folder "log/", "/srv/log", {
    :owner => "vagrant",
    :group => "www-data"
  }

  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for Apache sites. Put all
  # of your project files here that you want to access through the web server
  config.vm.synced_folder "www/", "/srv/www/", {
    :owner => "vagrant",
    :group => "www-data",
    :mount_options => ["dmode=775", "fmode=774"]
  }

  # Fix 'no tty' output
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Load in Customfile containing local projects and configuration
  customfile = File.join vagrant_dir, "Customfile"
  eval IO.read(customfile), binding if File.exist? customfile

  # Provisioning scripts
  provision_scripts = %w[
    profile
    packages
    xo
    node
    xo
    rvm
    mailcatcher
    php
    wp
    memcached
    opcached
    webgrind
    phpmyadmin
  ]
  provision_scripts.each do |script|
    config.vm.provision :shell, {
      :path => File.join("scripts", "provision", "#{script}.sh"),
      :name => script
    }
  end

  # Startup scripts (always run)
  startup_scripts = %w[
    apache
    certs
    services
    mysql
    sites
  ]
  startup_scripts.each do |script|
    config.vm.provision :shell, {
      :path => File.join("scripts", "startup", "#{script}.sh"),
      :run => "always"
    }
  end

  # Service restarts (always run)
  config.vm.provision :shell, {
    :inline => "sudo service mysql restart",
    :run => "always"
  }
  config.vm.provision :shell, {
    :inline => "sudo service apache2 restart",
    :run => "always"
  }

  # Custom provisioning scripts
  Dir[File.join("scripts", "custom", "*.sh")].each do |script|
    config.vm.provision :shell, :path => script
  end

  # If the vagrant-triggers plugin is installed, we can run various scripts on Vagrant
  # state changes like `vagrant up`, `vagrant halt`, `vagrant suspend`, and `vagrant destroy`
  #
  # These scripts are run on the host machine, so we use `vagrant ssh` to tunnel back
  # into the VM and execute things. By default, each of these scripts calls db_backup
  # to create backups of all current databases. This can be overridden with custom
  # scripting. See the individual files in config/homebin/ for details.
  if defined? VagrantPlugins::Triggers
    config.trigger.after :up, :stdout => true do
      run "vagrant ssh -c 'vagrant_up'"
    end
    config.trigger.before :reload, :stdout => true do
      run "vagrant ssh -c 'vagrant_halt'"
    end
    config.trigger.after :reload, :stdout => true do
      run "vagrant ssh -c 'vagrant_up'"
    end
    config.trigger.before :halt, :stdout => true do
      run "vagrant ssh -c 'vagrant_halt'"
    end
    config.trigger.before :suspend, :stdout => true do
      run "vagrant ssh -c 'vagrant_suspend'"
    end
    config.trigger.before :destroy, :stdout => true do
      run "vagrant ssh -c 'vagrant_destroy'"
    end
  end
end
