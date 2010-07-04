
include_recipe "ldap"

#
# Namespace
#

namespace = node[:components]

key = :ldap_client
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
      ['openldap', 'openldap-clients']
    else
      ['ldap-utils']
    end
end

if ! props.key?(:domain)
  domain = node[:domain]
  if domain.empty?
    props[:basedn] = ""
    props[:domain] = "127.0.0.1"
  else
    props[:domain] = "ldap.#{domain}"
    props[:basedn] = "dc=#{domain.split('.').join(",dc=")}"
  end
end

if ! props.key?(:protocol)
  props[:protocol] = "ldap://"
end
if ! props.key?(:reqcert)
  props[:reqcert] = 'allow'
end

# Use SSL CA certificates by default
if ! props.key?(:cafile)
  if ! props.key?(:cadir)
    if namespace.key?(:ssl)
      props[:cadir] = namespace[:ssl][:pkidir] + '/certs'
    end
  end
end

if ! namespace.key?(key)
  namespace[key] = props
end

include_recipe "ldap::client_enable"
