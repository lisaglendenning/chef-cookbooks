
include_attribute "accounts"

node.default[:components][:accounts][:ldap][:ssl] = 'start_tls'
