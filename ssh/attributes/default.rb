#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Default properties
#

default[:components][:ssl][:packages] = case node[:platform]
    when rhels
      ['openssh-clients', 'openssh']
    else
      ['openssh-client', 'openssh-server']
    end

default[:components][:ssl][:server][:transports] = [[:tcp, 22]]
