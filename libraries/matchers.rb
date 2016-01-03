if defined?(ChefSpec)
  def create_chef_server_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_user, :create, resource_name)
  end

  def create_chef_server_org(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:chef_server_org, :create, resource_name)
  end
end
