require "chef/resource/package"
require "chef/resource/apt_package"

class Chef::Resource::AptPackage < Chef::Resource::Package
  property :timeout, [String, Integer], desired_state: false, default: 1800
end
