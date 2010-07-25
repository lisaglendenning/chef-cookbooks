
#
# Default properties
#

include_attribute "ssl"

if node[:domain].empty?
  node.default[:components][:ldap][:client][:domain] = "localhost"
  node.default[:components][:ldap][:client][:basedn] = ""
else
  node.default[:components][:ldap][:client][:domain] = "ldap.#{node[:domain]}"
  node.default[:components][:ldap][:client][:basedn] = "dc=#{node[:domain].split('.').join(",dc=")}"
end

node.default[:components][:ldap][:client][:protocol] = "ldap://"
node.default[:components][:ldap][:client][:reqcert] = 'allow'

# Use SSL certificates by default
node.default[:components][:ldap][:client][:certdir] = node[:components][:ssl][:pkidir] + '/certs'
