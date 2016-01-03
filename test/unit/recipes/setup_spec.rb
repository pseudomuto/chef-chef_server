#
# Cookbook Name:: chef_server
# Spec:: setup
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

describe "chef_server::setup" do
  let(:setup_data) { YAML.load_file(File.join(SPEC_SETUP_DIR, "data.yml")) }

  cached(:chef_run) do
    runner = ChefSpec::SoloRunner.new do |node|
      node.set["chef_server"]["setup_dir"] = SPEC_SETUP_DIR
    end

    runner.converge(described_recipe)
  end

  it "converges successfully" do
    expect { chef_run }.to_not raise_error
  end

  it "creates a user for each one defined in data.yml" do
    properties = %w(first_name last_name email password)

    setup_data["users"].each do |user|
      data = properties.each_with_object({}) { |key, hash| hash[key] = user[key] }
      data.merge!(output_dir: SPEC_SETUP_DIR)

      expect(chef_run).to create_chef_server_user(user["username"]).with(data)
    end
  end

  it "creates an org based on data from data.yml" do
    org = setup_data["org"]

    expect(chef_run).to create_chef_server_org(org["name"]).with(
      full_name: org["full_name"],
      users: org["users"],
      output_dir: SPEC_SETUP_DIR
    )
  end
end
