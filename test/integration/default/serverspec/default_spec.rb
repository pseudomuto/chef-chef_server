require "spec_helper"

describe "chef_server" do
  describe command("hostname") do
    its(:exit_status) { should eq(0) }
    its(:stdout) { should eq("chef.sweeper.io\n") }
  end

  describe file("/etc/hosts") do
    def define_entry(ip, host)
      match(/^#{Regexp.escape(ip)}.*\s+#{Regexp.escape(host)}/)
    end

    its(:content) { should define_entry("127.0.0.1", "chef.sweeper.io") }
  end

  describe file("/var/opt/opscode/nginx/ca/chef.sweeper.io.crt") do
    it { should exist }
  end

  describe file("/var/opt/opscode/nginx/ca/chef.sweeper.io.key") do
    it { should exist }
  end

  describe file("/etc/opscode/chef-server.rb") do
    def define_setting(name, value)
      match(/^#{Regexp.escape(name)}\s*=?\s*#{Regexp.escape(value)}/)
    end

    its(:content) { should define_setting("api_fqdn", '"chef.sweeper.io"') }
    its(:content) { should define_setting('nginx["non_ssl_port"]', "false") }
    its(:content) { should define_setting('nginx["ssl_company_name"]', '"sweeper.io"') }
    its(:content) { should define_setting('nginx["ssl_email_address"]', '"developers@sweeper.io"') }
    its(:content) { should define_setting('nginx["ssl_locality_name"]', '"Ottawa"') }
    its(:content) { should define_setting('nginx["ssl_state_name"]', '"ON"') }
    its(:content) { should define_setting('nginx["ssl_country_name"]', '"CA"') }
    its(:content) { should define_setting("notification_email", '"developers@sweeper.io"') }
    its(:content) { should define_setting("topology", '"standalone"') }
  end

  describe package("chef-server-core") do
    it { should be_installed }
  end

  describe command("chef-client -v") do
    its(:exit_status) { should eq(0) }
    its(:stdout) { should eq("Chef: 12.6.0\n") }
  end

  context "users and organizations" do
    %w(sweeperadmin pseudomuto).each do |user|
      describe command("chef-server-ctl list-user-keys #{user}") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match(/name: default\nexpired: false/) }
      end

      describe file("/tmp/chef-setup/#{user}.tar.gz") do
        it { should exist }
      end
    end

    describe command("chef-server-ctl org-show sweeper") do
      its(:exit_status) { should eq(0) }
      its(:stdout) { should match(/^name:\s*sweeper$/) }
      its(:stdout) { should match(/^full_name:\s*sweeper\.io$/) }
    end
  end

  describe command("chef-server-ctl test") do
    its(:exit_status) { should eq(0) }
  end
end
