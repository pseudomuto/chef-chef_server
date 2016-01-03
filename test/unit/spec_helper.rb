require "chefspec"
require "chefspec/berkshelf"

Dir["./libraries/**/*.rb"].each { |f| require f }
Dir["./test/unit/support/**/*.rb"].each { |f| require f }

SPEC_SETUP_DIR = File.join(Dir.pwd, "test", "fixtures")

module CommonRecipeContext
  extend RSpec::SharedContext

  let(:spec_node) do
    chef_node = Chef::Node.new
    chef_node.set["chef_server"]["setup_dir"] = SPEC_SETUP_DIR
    chef_node
  end

  let(:config) { SetupConfig.initialize(spec_node) }
end

class Runner < ChefSpec::SoloRunner
  def initialize(config, options = {})
    super(options)
  end
end

RSpec.configure do |config|
  config.log_level = :fatal
  config.platform  = "ubuntu"
  config.version   = "14.04"

  config.include CommonRecipeContext
end
