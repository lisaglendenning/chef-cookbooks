

# I'm confused about how to determine when or whether attributes get loaded
# So I'm stickin em all in here

#
# Client Defaults
#

if ! domain.empty?
  default[:ldap][:domain] = "ldap.#{domain}"
  default[:ldap][:basedn] = "dc=#{domain.split('.').join(",dc=")}"
end

default[:ldap][:basedn] = ""
default[:ldap][:domain] = "127.0.0.1"
default[:ldap][:protocol] = "ldap://"
default[:ldap][:reqcert] = 'allow'
