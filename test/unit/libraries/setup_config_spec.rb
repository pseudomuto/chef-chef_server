describe SetupConfig do
  before(:each) { expect(config).to_not be_nil }

  it "allows access to values via raw method" do
    expect(config.raw("knife").key?("cookbook_copyright")).to be true
  end

  it "sets attributes on the node" do
    expect(spec_node["chef-server"]["api_fqdn"]).to eq(config.server.fqdn)
    expect(spec_node["chef-server"]["topology"]).to eq(config.server.topology)
    expect(spec_node["chef-server"]["version"]).to eq(config.server.version)
    expect(spec_node["chef-server"]["configuration"]).to eq(config.server.configuration)
  end

  it "sets knife properties" do
    expect(config.knife.cookbook_copyright).to eq("sweeper.io")
    expect(config.knife.cookbook_email).to eq("developers@sweeper.io")
    expect(config.knife.cookbook_license).to eq("mit")
    expect(config.knife.data_bag_encrypt_version).to eq(2)
  end

  it "sets client properties" do
    expect(config.client.version).to eq("12.6.0")
  end

  it "sets server properties" do
    expect(config.server.fqdn).to eq("chef.sweeper.io")
    expect(config.server.topology).to eq("standalone")
    expect(config.server.version).to eq("12.3.1")

    expect(config.server.configuration).to include('notification_email "developers@sweeper.io"')
    expect(config.server.configuration).to include('nginx["ssl_locality_name"] = "Ottawa"')
  end

  it "sets users appropriately" do
    expect(config.users.size).to be(2)
    expect(config.users.first.username).to eq("sweeperadmin")
    expect(config.users.last.username).to eq("pseudomuto")
  end

  it "sets org appropriately" do
    expect(config.org.name).to eq("sweeper")
    expect(config.org.users["admins"]).to eq(%w(sweeperadmin))
    expect(config.org.users["users"]).to eq(%w(pseudomuto))
  end
end
