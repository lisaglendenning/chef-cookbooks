#
# Cookbook Name:: ssh
# Recipe:: default
#
# Copyright 2010, www.cs.washington.edu
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

#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Packages
#

packages = case node[:platform]
  when rhels
    ['openssh-clients', 'openssh']
  else
    ['openssh-client', 'openssh-server']
  end
  
packages.each { |p|
  package p do
   action :upgrade
  end
}

#
# Configuration
#

#
# Platform-specific paths
#

CONFDIR = '/etc/ssh'
CONFFILE = CONFDIR + '/sshd_config'

template CONFFILE do
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
end

#
# Services
#

service "ssh" do
  case node[:platform]
  when rhels
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true
  action [:enable, :start]
  subscribes :restart, resources(:template => CONFFILE)
end
