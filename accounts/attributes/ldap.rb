# autodetect if LDAP is enabled
# unless explicitly disabled with false
if !node.components.attribute?(:accounts) || !node.components.accounts.attribute?(:ldap) || node[:components][:accounts][:ldap][:enabled].nil?
  has_ldap = node.components.attribute?(:ldap) && node.components.ldap.attribute?(:client)
  node.set[:components][:accounts][:ldap][:enabled] = has_ldap ? true : nil
end


# accounts::ldap attributes can be used to specialize ldap::client attributes

if node[:components][:accounts][:ldap][:enabled]
  node.default[:components][:accounts][:ldap][:ssl] = 'start_tls'
end
