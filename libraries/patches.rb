require "chef/resource/package"
require "chef/resource/apt_package"

class Chef::Resource::AptPackage < Chef::Resource::Package
  property :timeout, [String, Integer], desired_state: false, default: 1800
end

class Hash
  def symbolize_keys!
    keys.each { |key| self[key.to_sym] = delete(key) }
    self
  end
end
