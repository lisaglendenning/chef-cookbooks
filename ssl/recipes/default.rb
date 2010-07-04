
#
# Namespace
#

namespace = node[:components]

key = :ssl
if namespace.key?(key)
  props = namespace[key]
else
  props = Mash.new
end

#
# Supported Platforms
#

rhels = ['redhat', 'centos', 'fedora']

if ! props.key?(:packages)
  props[:packages] = ['openssl']  
end

if ! props.key?(:pkidir)
  props[:pkidir] = case node[:platform]
    when rhels
      '/etc/pki/tls'
    else
      '/etc/ssl'
    end
end

if ! namespace.key?(key)
  namespace[key] = props
end

include_recipe "ssl::default_enable"
