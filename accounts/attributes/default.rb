
rhels = ['redhat', 'centos', 'fedora']

# LDAP enabled?
default[:components][:accounts][:ldap] = node[:components].key?(:ldap_client)

packages = ['nscd', 'autodir']
if components[:accounts][:ldap]
  packages.concat(case node[:platform]
  when rhels
    ['libnss-ldap', 'libpam-ldap']
  else
    ['auth-client-config', 'libnss-ldap', 'libpam-ldap', 
     'ldap-auth-config', 'ldapscripts', 'autodir']
  end)

  default[:components][:accounts][:ldap][:uri] = \
    node[:components][:ldap_client][:protocol] + node[:components][:ldap_client][:domain]
  default[:components][:accounts][:ldap][:basedn] = \
    node[:components][:ldap_client][:basedn]
  default[:components][:accounts][:ldap][:ssl] = 'start_tls'

end

default[:components][:accounts][:packages] = packages
  
default[:components][:accounts][:autodir][:autohome] = true
default[:components][:accounts][:autodir][:autogroup] = false

default[:components][:accounts][:admins] = []
default[:components][:accounts][:sudoers] = case node[:platform]
when rhels
  ['%wheel']
else
  ['%admin']
end
