#
# Namespace
#

namespace = node[:components]

key = :ssh
if namespace.key?(key)
  props = namespace[key]
else
  props = Mash.new
end

#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

#
# Default properties
#

if ! props.key?(:packages)
  props[:packages] = case node[:platform]
    when rhels
      ['openssh-clients', 'openssh']
    else
      ['openssh-client', 'openssh-server']
    end
end

if ! props.key?(:server)
  props[:server] = Mash.new
  props[:server][:transports] = [[:tcp, 22]]
end  

if ! namespace.key?(key)
  namespace[key] = props
end

node[:components].each { |k,v|
  Chef::Log.info(k.to_s)
  Chef::Log.info(v.to_s)
}

include_recipe "ssh::default_enable"
