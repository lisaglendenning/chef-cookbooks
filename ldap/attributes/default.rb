
rhels = ['redhat', 'centos', 'fedora']
  
#
# Look for a registered ldap server
#

ldap_server = nil
search(:node, "*:*") do |n|
  if n[:components] && n[:components].key?(:ldap_server) && n[:components][:ldap_server].key?(:ldap_client)
    ldap_server = n
    break
  end
end


#
# Default properties
#

default[:components][:ldap_client][:packages] = case node[:platform]
  when rhels
    ['openldap', 'openldap-clients']
  else
    ['ldap-utils']
  end

if ldap_server
  default[:components][:ldap_client][:domain] = ldap_server[:components][:ldap_server][:ldap_client][:domain]
  default[:components][:ldap_client][:basedn] = ldap_server[:components][:ldap_server][:ldap_client][:basedn]
  default[:components][:ldap_client][:protocol] = ldap_server[:components][:ldap_server][:ldap_client][:protocol]
  default[:components][:ldap_client][:reqcert] = ldap_server[:components][:ldap_server][:ldap_client][:reqcert]
else
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
end
