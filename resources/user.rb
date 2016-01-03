default_action :create

property :username, String, name_property: true
property :first_name, String, required: true
property :last_name, String, required: true
property :email, String, required: true
property :password, String, required: true
property :output_dir, String, required: true

action :create do
  execute "create chef user #{new_resource.username}" do
    command new_resource.create_command
    not_if "chef-server-ctl user-list | grep '#{new_resource.username}'"
  end
end

def create_command
  format(
    "chef-server-ctl user-create %s %s %s %s %s --filename %s/%s.pem",
    username,
    first_name,
    last_name,
    email,
    password,
    output_dir,
    username
  )
end
