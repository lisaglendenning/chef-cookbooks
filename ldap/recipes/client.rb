#
# Cookbook Name:: ldap
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
    ['openssl', 'openldap', 'openldap-clients']
  else
    ['openssl', 'ldap-utils']
  end
packages.each { |p|
  package p do
	 action :install
  end
}

#
# Configuration
#

#
# Platform-specific paths
#

CONFDIR = case node[:platform]
  when rhels
    "/etc/openldap"
  else
    "/etc/ldap"
  end
CONFFILE = CONFDIR + "/ldap.conf"

SSLDIR = case node[:platform]
  when rhels
    "/etc/pki/tls/certs"
  else
    '/etc/ssl/certs'
  end

# Use SSL CA certificates by default
if ! node[:ldap][:cafile]
  if ! node[:ldap][:cadir]
    node[:ldap][:cadir] = SSLDIR
  end
end

template CONFFILE do
  source "ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
end
