#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Uses the Passenger gem install and associated execute command to install nginx to ensure version 
#   match between passenger-helper and nginx.  NOTE:  This means nginx is NOT PACKAGED so idempotency is
#   reduced/broken.  Exercise care.  This recipe does *NOT* use 'runit' as the Opscode one does; it uses the
#   Debian/ubunut SYSVINIT system (installs /etc/init.d/nginx).


# Ensure that nginx's prerequisites are installed

include_recipe "build-essential"

%w{ libpcre3 libpcre3-dev libssl-dev zlib1g-dev libperl-dev }.each do |devpkg|
  package devpkg
end

# Ensure that the passenger gem is installed

gem_package "passenger" do
  version "#{node[:nginx][:passengerversion]}"
end


# Install nginx using passenger script.

configure_flags = node[:nginx][:configure_flags].join(" ")


execute "passenger-install-nginx" do
  command "passenger-install-nginx-module --auto --auto-download --prefix=#{node[:nginx][:install_path]} --extra-configure-flags='#{confgure_flags}'"
  creates "#{node[:nginx][:install_path]}/sbin/nginx"
end

# Install /etc/init.d/nginx 

template "/etc/init.d/nginx" do
  owner "root"
  group "root"
  mode "0644"
  source "init_d-nginx.erb"
end

execute "update-rcd" do
  command "update-rc.d nginx defaults"
  creates "/etc/rc0.d/K20nginx"
end


# Set up nginx

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end


# Start nginx service

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
