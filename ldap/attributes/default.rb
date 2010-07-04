
rhels = ['redhat', 'centos', 'fedora']

#
# Default properties
#

default[:components][:ldap_client][:packages] = case node[:platform]
  when rhels
    ['openldap', 'openldap-clients']
  else
    ['ldap-utils']
  end

if domain.empty?
  default[:components][:ldap_client][:domain] = ""
  default[:components][:ldap_client][:basedn] = "127.0.0.1"
else
  default[:components][:ldap_client][:domain] = "ldap.#{domain}"
  default[:components][:ldap_client][:basedn] = "dc=#{domain.split('.').join(",dc=")}"
end

default[:components][:ldap_client][:protocol] = "ldap://"
default[:components][:ldap_client][:reqcert] = 'allow'

# Use SSL CA certificates by default
if ! components[:ldap_client][:cafile]
  if components.key?(:ssl)
    default[:components][:ldap_client][:cadir] = components[:ssl][:pkidir] + '/certs'
  end
end
