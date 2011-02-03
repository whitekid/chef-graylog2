#
# Cookbook Name:: graylog2
# Recipe:: web-interface
#
# Copyright 2010, Medidata Solutions Inc.
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

# Install graylog2 server
include_recipe "graylog2::default"

# Ensure bundler is available
gem_package "bundler" do
  version "1.0.3"  # Put in for our infrastructure requirements at MDSOL
  action :install
end

# Ensure rake is available
gem_package "rake" do
  action :install
end

# Install required apt packages
%w{ build-essential make rrdtool rake libopenssl-ruby libmysqlclient-dev ruby-dev mysql-server }.each do |pkg|
  package pkg do
    action :install
  end
end

# Make sure app directory exists
directory "#{node[:graylog2][:basedir]}/src" do
  owner "root"
  group "root"
  mode 0755
  action :create
  recursive true
end

# use remote_file to grab the desired version of graylog2-web-interface
remote_file "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz" do
  source "https://github.com/downloads/Graylog2/graylog2-web-interface/graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz"
  action :create_if_missing
end

# unpack graylog2-web-interface
execute "unpack_graylog2_webui" do
  cwd "#{node[:graylog2][:basedir]}/src"
  command "tar zxf graylog2-web-interface-#{node[:graylog2][:webuiversion]}.tar.gz"
  creates "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}/build_date"
end

# Link graylog2-web-interface
link "#{node[:graylog2][:basedir]}/web" do
  to "#{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}"
end

# Perform bundle install on newly-installed webui rails project
execute "webui_bundle" do
  cwd "#{node[:graylog2][:basedir]}/web"
  command "bundle install"
  not_if "cd #{node[:graylog2][:basedir]}/web && bundle check | grep 'dependencies are satisfied'"
 end

# Create log directory
directory "#{node[:graylog2][:basedir]}/web/log" do
  owner "nobody"
  group "nogroup"
  mode 0755
end

# Chown the graylog2 directory to nobody/nogroup to allow web servers to serve it
execute "webui_chown" do
  cwd "#{node[:graylog2][:basedir]}/src"
  command "sudo chown -R nobody:nogroup #{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]}"
  not_if "ls -ald #{node[:graylog2][:basedir]}/src/graylog2-web-interface-#{node[:graylog2][:webuiversion]} | grep \"nobody nogroup\""
end

# Install database.yml
template "webui_database-yml" do
  path "#{node[:graylog2][:basedir]}/web/config/database.yml"
  source "database_yml.erb"
  owner "nobody"
  group "nogroup"
  mode 0644
end

# Install general.yml
template "webui_general-yml" do
  path "#{node[:graylog2][:basedir]}/web/config/general.yml"
  source "general_yml.erb"
  owner "nobody"
  group "nogroup"
  mode 0644
end

# Perform rake db:create if necessary
execute "webui_rake_dbcreate" do
  cwd "#{node[:graylog2][:basedir]}/web"
  command "sudo -u nobody rake db:create RAILS_ENV=production && touch ./.db_created"
  not_if "test -f #{node[:graylog2][:basedir]}/web/.db_created"  # Ooh, the hack.
end

# Perform rake db:migrate if necessary
execute "webui_rake_dbmigrate" do
  cwd "#{node[:graylog2][:basedir]}/web"
  command "sudo -u nobody rake db:migrate RAILS_ENV=production && touch ./.db_migrated"
  not_if "test -f #{node[:graylog2][:basedir]}/web/.db_migrated" # Ooh, the hack.
end

# Install apache site template
