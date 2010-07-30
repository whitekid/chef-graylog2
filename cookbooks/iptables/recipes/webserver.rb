#
# Cookbook Name:: iptables
# Recipe:: webserver
#
# Copyright 2001, Medidata Solutions, Inc.
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

# Include the default iptables recipe just in case it hasn't been run
include_recipe "iptables::default"

iptables_rule "all_http"
iptables_rule "all_https"
