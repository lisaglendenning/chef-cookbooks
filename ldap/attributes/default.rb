
#
# Default properties
#

include_attribute "ssl"

default[:components][:ldap_client][:packages] = case node[:platform]
  when 'redhat', 'centos', 'fedora'
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

# Use SSL certificates by default
if components.key?(:ssl) && components[:ssl].key?(:pkidir)
  default[:components][:ldap_client][:certdir] = components[:ssl][:pkidir] + '/certs'
end
