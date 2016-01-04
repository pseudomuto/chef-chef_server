# chef_server

[![Build Status](https://travis-ci.org/sweeperio/chef-chef_server.svg?branch=master)](https://travis-ci.org/sweeperio/chef-chef_server)

Installs and configures a standalone chef server!

## What It Does

Since this cookbook is not meant to be included in a role or anything (cuz you don't have a chef server yet), data is
pulled from a file called `/tmp/chef-setup/data.yml`, rather than using attributes. 

This  means you don't necessarily have to fork this repo (though you're welcome to) to customize it and get started.

**Checkout [the fixture file] for an example of a valid yml config**

Using the definitions in `/tmp/chef-setup/data.yml` this will:

* Set the hostname for the machine to `server.fqdn`
* Install and configure a chef server using settings from `server` (via the [chef-server cookbook])
* Create users for each user defined in `users`
* Create an organization using values defined in `org`
* Add users to the org (see `org.users`)
* Generate a tar file for each user in `/tmp/chef-setup` containing:
    * the user's pem file
    * the validator pem file for the organization
    * a common `encrypted_data_bag_secret` file
    * a `trusted_certs` directory containing the SSL cert that was generated during the install process
    * a `knife.rb` configured to work with the org (and the above files)

Once this has run, you can grab your tar file from `/tmp/chef-setup/<username>.tar.gz` and extract it on your
workstation (usually in `~/.chef`).

The knife file will look something like this (depending on your yml settings):

```ruby
current_dir = File.dirname(__FILE__)

log_level                 :info
log_location              STDOUT

cookbook_copyright        "sweeper.io"
cookbook_email            "developers@sweeper.io"
cookbook_license          "mit"
data_bag_encrypt_version  2

node_name                 "pseudomuto"
client_key                "#{current_dir}/pseudomuto.pem"
validation_client_name    "sweeper-validator"
validation_key            "#{current_dir}/sweeper-validator.pem"
chef_server_url           "https://chef.sweeper.io/organizations/sweeper"
encrypted_data_bag_secret "#{current_dir}/encrypted_data_bag_secret"

if defined?(ChefDK::CLI)
  begin
    require "chef_gen/flavors"
    chefdk.generator_cookbook = ChefGen::Flavors.path
  rescue LoadError
  end
end
```

**What It Doesn't**

* Install any add on packages (manager, chef-ha, reporting, etc.). You'll just have `chef-server-ctl`

## Usage

To install your chef server, you need to:

* Put your yml config in `/tmp/chef-setup/data.yml`
* Copy [the install script] to the server
* Run `sudo ./install.sh` (you _**really**_ should read the script first)

### Test First

During development, I found it was nice to be able to test out the install script on a throwaway box. Just to make sure
that everything gets created properly, etc.

If you'd like to test out the installation process before setting up your AWS/Digital Ocean/Rackspace, etc. server,
there's a Vagrant file in this repo.

You'll need to update a couple of things, but nothing complicated, I promise.

[the fixture file]: https://github.com/sweeperio/chef-chef_server/blob/master/test/fixtures/data.yml
[chef-server cookbook]: https://github.com/chef-cookbooks/chef-server
[the install script]: https://github.com/sweeperio/chef-chef_server/blob/master/install.sh
