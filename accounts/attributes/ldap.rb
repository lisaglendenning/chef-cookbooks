
include_attribute "accounts"

if node.recipes.include?("accounts::ldap")
  node.default[:components][:accounts][:ldap][:ssl] = 'start_tls'
end
