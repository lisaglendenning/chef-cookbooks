#
# Namespace
#

#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Default properties
#

if ! node[:components][:ssl][:packages]
  node[:components][:ssl][:packages] = case node[:platform]
    when rhels
      ['openssh-clients', 'openssh']
    else
      ['openssh-client', 'openssh-server']
    end
end

if ! node[:components][:ssl][:server]
  node[:components][:ssl][:server] = Mash.new
  node[:components][:ssl][:server][:transports] = [[:tcp, 22]]
end  

include_recipe "ssh::default_enable"
