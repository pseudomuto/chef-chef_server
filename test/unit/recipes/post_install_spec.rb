#
# Cookbook Name:: chef_server
# Spec:: post_install
#
# The MIT License (MIT)
#
# Copyright (c) 2016 sweeper.io
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

describe "chef_server::post_install" do
  def all_users
    config.users.each { |user| yield(user.username) }
  end

  cached(:chef_run) do
    runner = Runner.new(config)
    runner.converge(described_recipe)
  end

  it "converges successfully" do
    expect { chef_run }.to_not raise_error
  end

  it "creates a user package for each user" do
    all_users do |user|
      expect(chef_run).to create_chef_server_user_package(user)
    end
  end

  context "when stepping into resource" do
    let(:chef_run) do
      runner = Runner.new(config, step_into: %w(chef_server_user_package))
      runner.converge(described_recipe)
    end

    describe "and no users were created during this run" do
      before(:each) do
        allow(File).to receive(:exist?).and_call_original

        all_users do |user|
          path = File.join(SetupConfig.instance.path, "#{user}.pem")
          allow(File).to receive(:exist?).with(path).and_return(false)
        end
      end

      it "shouldn't create an encrypted_data_bag_secret" do
        expect(chef_run).to_not run_execute("generate encrypted_data_bag_secret")
      end
    end

    describe "and users were created during this run" do
      before(:each) do
        allow(File).to receive(:exist?).and_call_original

        all_users do |user|
          path = File.join(SetupConfig.instance.path, "#{user}.pem")
          allow(File).to receive(:exist?).with(path).and_return(true)
        end
      end

      it "generates an encrypted_data_bag_secret file" do
        expect(chef_run).to run_execute("generate encrypted_data_bag_secret")
      end

      it "creates the user directory" do
        all_users do |user|
          expect(chef_run).to create_directory(File.join(config.path, user, config.client.chef_dir, "trusted_certs")).with(
            recursive: true
          )
        end
      end

      it "copies pem and secret files into the user's directory" do
        all_users do |user|
          expect(chef_run).to run_execute("copy pem and secret files to #{user}/ directory")
        end
      end

      it "copies the self-signed cert to user/chef_dir/trusted_certs" do
        all_users do |user|
          expect(chef_run).to run_execute("copy trusted certificate")
        end
      end

      it "generates knife.rb for each user" do
        all_users do |user|
          expect(chef_run).to create_template("#{config.path}/#{user}/#{config.client.chef_dir}/knife.rb").with(
            source: "knife.rb.erb",
            variables: {
              cookbook_copyright: config.knife.cookbook_copyright,
              cookbook_email: config.knife.cookbook_email,
              cookbook_license: config.knife.cookbook_license,
              data_bag_encrypt_version: config.knife.data_bag_encrypt_version,
              org_name: config.org.name,
              server_name: config.server.fqdn,
              username: user
            }
          )
        end
      end

      it "tars up the chef dir for each user" do
        all_users do |user|
          expect(chef_run).to run_execute("tar the .chef directory for #{user}")
        end
      end

      it "cleans up user temp files" do
        all_users do |user|
          expect(chef_run).to run_execute("clean up temp files for #{user}")
        end
      end
    end

    it "cleans up global temp files" do
      expect(chef_run).to run_execute("clean up global temp files")
    end
  end
end
