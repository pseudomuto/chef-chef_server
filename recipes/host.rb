#
# Cookbook Name:: chef_server
# Recipe:: host
#
# The MIT License (MIT)
#
# Copyright (c) 2016 sweeper.io
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

hostname = SetupConfig.instance.server.fqdn

ohai "reload_hostname" do
  plugin "hostname"
  action :nothing
end

file "/etc/hostname" do
  content "#{hostname}\n"
  notifies :reload, "ohai[reload_hostname]", :immediately
end

execute "hostname #{hostname}" do
  not_if { node["hostname"] == hostname }
  notifies :reload, "ohai[reload_hostname]", :immediately
end

hostsfile_entry "127.0.0.1" do
  hostname hostname
  aliases %w(localhost)
  comment "added by chef_server"
  unique true
  action :append
end
