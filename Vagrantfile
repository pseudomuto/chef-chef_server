Vagrant.configure("2") do |c|
  c.berkshelf.enabled = false if Vagrant.has_plugin?("vagrant-berkshelf")
  c.vm.box = "opscode-ubuntu-14.04"
  c.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box"
  c.vm.hostname = "chef.sweeper.io"
  c.vm.synced_folder ".", "/vagrant", disabled: true
  c.vm.synced_folder "/Users/pseudomuto/Code/chef-chef_server/test/fixtures", "/tmp/chef-setup", create: true
  c.vm.provider :vmware_fusion do |p|
    p.vmx["memsize"] = "4096"
  end
end
