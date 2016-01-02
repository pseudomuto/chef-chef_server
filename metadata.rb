# rubocop:disable Style/SingleSpaceBeforeFirstArg
name             "chef_server"
maintainer       "sweeper.io"
maintainer_email "developers@sweeper.io"
license          "mit"
description      "Installs/Configures a standalone chef server"
long_description "Installs/Configures a standalone chef server"
version          "0.1.0"
# rubocop:enable Style/SingleSpaceBeforeFirstArg

supports "ubuntu"

depends "chef-ingredient",  "~> 0.0"
depends "chef-server",      "~> 4.0"
depends "hostsfile",        "~> 2.0"
depends "packagecloud",     "~> 0.0"

chef_version ">= 12.5" if respond_to?(:chef_version)
source_url "YOUR SOURCE REPO URL" if respond_to?(:source_url)
issues_url "WHERE TO LOG ISSUES" if respond_to?(:issues_url)
