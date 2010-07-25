
# autodetect if LDAP is enabled
# unless explicitly disabled with false
if !node.components.attribute?(:accounts) || !node.components.accounts.attribute?(:ldap) || node[:components][:accounts][:ldap][:enabled].nil?
  has_ldap = node.components.attribute?(:ldap) && node.components.ldap.attribute?(:client)
  node.set[:components][:accounts][:ldap][:enabled] = has_ldap ? true : nil
end

if components[:accounts][:ldap][:enabled]
  node.set[:components][:accounts][:ldap][:uri] = \
    "#{node[:components][:ldap][:client][:protocol]}#{node[:components][:ldap][:client][:domain]}"
  node.set[:components][:accounts][:ldap][:basedn] = \
    node[:components][:ldap][:client][:basedn]
  node.default[:components][:accounts][:ldap][:ssl] = 'start_tls'
end
  
node.default[:components][:accounts][:autodir][:autohome] = true
node.default[:components][:accounts][:autodir][:autogroup] = false

node.default[:components][:accounts][:admins] = []
node.default[:components][:accounts][:sudoers] = case node[:platform]
when 'redhat', 'centos', 'fedora'
  ['%wheel']
else
  ['%admin']
end
