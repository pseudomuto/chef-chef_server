class SetupConfig
  private_class_method :new

  attr_reader :path

  class << self
    attr_reader :instance

    def initialize(node)
      @instance = new(node)
    end
  end

  def initialize(node) # rubocop:disable Metrics/AbcSize
    @path = node["chef_server"]["setup_dir"]

    node.set["chef-server"]["api_fqdn"]      = server.fqdn
    node.set["chef-server"]["topology"]      = server.topology
    node.set["chef-server"]["version"]       = server.version
    node.set["chef-server"]["configuration"] = server.configuration
  end

  def raw(key)
    data[key]
  end

  def knife
    @knife ||= OpenStruct.new(data["knife"])
  end

  def client
    @client ||= OpenStruct.new(data["client"])
  end

  def server
    @server ||= OpenStruct.new(data["server"])
  end

  def users
    @users ||= data["users"].map(&OpenStruct.method(:new))
  end

  def org
    @org ||= OpenStruct.new(data["org"])
  end

  private

  def data
    @data ||= YAML.load_file(File.join(path, "data.yml"))
  end
end
