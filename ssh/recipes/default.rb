#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Default properties
#

default[:components][:ssh][:packages] = case node[:platform]
    when rhels
      ['openssh-clients', 'openssh']
    else
      ['openssh-client', 'openssh-server']
    end

default[:components][:ssh][:server][:transports] = [[:tcp, 22]]

include_recipe "ssh::default_enable"
