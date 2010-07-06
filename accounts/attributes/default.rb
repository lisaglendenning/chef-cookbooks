
# autodetect if LDAP is enabled
# unless explicitly disabled with false
if components[:accounts][:hasldap] == nil || components[:accounts][:hasldap] != false
  has_ldap = node[:components].key?(:ldap_client)
  if has_ldap
    has_ldap = components[:ldap_client].key?(:protocol) &&
      components[:ldap_client].key?(:domain) &&
      components[:ldap_client].key?(:basedn)
  end
  set[:components][:accounts][:hasldap] = has_ldap ? true : nil
end

packages = ['nscd', 'autodir']
if components[:accounts][:hasldap]
  ldap_packages = case node[:platform]
  when 'redhat', 'centos', 'fedora'
    ['nss-ldap']
  else
    ['auth-client-config', 'libnss-ldap', 'libpam-ldap', 
     'ldap-auth-config', 'ldapscripts', 'autodir']
  end
  packages.concat(ldap_packages)

  default[:components][:accounts][:ldap][:uri] = \
    node[:components][:ldap_client][:protocol] + node[:components][:ldap_client][:domain]
  default[:components][:accounts][:ldap][:basedn] = \
    node[:components][:ldap_client][:basedn]
  default[:components][:accounts][:ldap][:ssl] = 'start_tls'

  if components[:accounts][:packages]
    missing = components[:accounts][:packages] - packages
      if missing
        set[:components][:accounts][:packages] = packages
      end
  end
end

default[:components][:accounts][:packages] = packages
  
default[:components][:accounts][:autodir][:autohome] = true
default[:components][:accounts][:autodir][:autogroup] = false

default[:components][:accounts][:admins] = []
default[:components][:accounts][:sudoers] = case node[:platform]
when 'redhat', 'centos', 'fedora'
  ['%wheel']
else
  ['%admin']
end
