require "spec_helper"

describe "chef_server" do
  describe command("hostname -f") do
    its(:exit_status) { should eq(0) }
    its(:stdout) { should eq("chef.sweeper.io\n") }
  end

  describe file("/etc/hosts") do
    its(:content) { should match(/127.0.1.1\s*chef.sweeper.io/) }
  end

  describe file("/etc/opscode/chef-server.rb") do
    its(:content) { should match(/^topology "standalone"$/) }
    its(:content) { should match(/^api_fqdn "chef.sweeper.io"$/) }
  end

  describe package("chef-server-core") do
    it { should be_installed }
  end
end
