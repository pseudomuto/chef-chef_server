default_action :create

property :user, String, name_property: true

load_current_value do
  path = ::File.join(SetupConfig.instance.path, user, ".pem")
  current_value_does_not_exist! unless ::File.exist?(path)
end

action :create do
  return if current_resource.nil?

  %i(
    generate_encrypted_data_bag_secret
    create_directory
    copy_files
    copy_trusted_certificate
    generate_knife_file
    tar_up_the_chef_dir
    clean_up_user_files
  ).each { |method| new_resource.public_send(method, self) }
end

def generate_encrypted_data_bag_secret(context)
  context.execute "generate encrypted_data_bag_secret" do
    command "openssl rand -base64 512 | tr -d '\r\n' > encrypted_data_bag_secret"
    cwd SetupConfig.instance.path
    not_if { ::File.exist?("encrypted_data_bag_secret") }
  end
end

def create_directory(context)
  context.directory "#{working_dir}/trusted_certs" do
    recursive true
  end
end

def copy_files(context)
  files    = [
    "#{user}.pem",
    "#{SetupConfig.instance.org.name}-validator.pem",
    "encrypted_data_bag_secret"
  ]

  command = "cp #{files.join(' ')} #{working_dir}/"

  context.execute "copy pem and secret files to #{user}/ directory" do
    command command
    cwd SetupConfig.instance.path
  end
end

def copy_trusted_certificate(context)
  cert_path = "/var/opt/opscode/nginx/ca/#{SetupConfig.instance.server.fqdn}.crt"
  command   = "cp #{cert_path} #{working_dir}/trusted_certs/"

  context.execute "copy trusted certificate" do
    command command
    cwd SetupConfig.instance.path
  end
end

def generate_knife_file(context)
  options = SetupConfig.instance.raw("knife").symbolize_keys!.merge(
    org_name: SetupConfig.instance.org.name,
    server_name: SetupConfig.instance.server.fqdn,
    username: user
  )

  context.template "#{working_dir}/knife.rb" do
    source "knife.rb.erb"
    variables options
  end
end

def tar_up_the_chef_dir(context)
  tar_file = "#{user}.tar.gz"
  command  = "tar -zcf #{tar_file} #{SetupConfig.instance.client.chef_dir} && mv #{tar_file} ../"
  path     = user_dir

  context.execute "tar the .chef directory for #{user}" do
    command command
    cwd path
  end
end

def clean_up_user_files(context)
  command = "rm -rf #{user}/ #{user}.pem"
  path    = SetupConfig.instance.path

  context.execute "clean up temp files for #{user}" do
    command command
    cwd path
  end
end

private

def user_dir
  ::File.join(SetupConfig.instance.path, user)
end

def working_dir
  ::File.join(user_dir, SetupConfig.instance.client.chef_dir)
end
