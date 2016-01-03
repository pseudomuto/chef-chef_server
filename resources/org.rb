default_action :create

property :name, String, name_property: true
property :full_name, String, required: true
property :users, Hash, default: lazy { Hash.new }
property :output_dir

load_current_value do
  current_value_does_not_exist! if `chef-server-ctl org-list | grep '#{name}'`.chomp.empty?
end

action :create do
  return unless current_resource.nil?

  users = []
  new_resource.users["admins"].each_with_object(users) { |name, array| array << [name, true] }
  new_resource.users["users"].each_with_object(users) { |name, array| array << [name, false] }

  execute "create chef organization" do
    command new_resource.create_command
  end

  users.each do |user, admin|
    execute "associate #{user} with the #{new_resource.name} org" do
      command new_resource.add_user_command(user, admin: admin)
    end
  end
end

def create_command
  format(
    "chef-server-ctl org-create %s \"%s\" -f %s/%s-validator.pem",
    name,
    full_name,
    output_dir,
    name
  )
end

def add_user_command(username, admin: false)
  cmd = "chef-server-ctl org-user-add #{name} #{username}"
  cmd << " -a" if admin
  cmd
end
