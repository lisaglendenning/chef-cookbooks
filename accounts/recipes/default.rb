
if node[:recipes].include?("accounts::local")
  include_recipe "accounts::local"
end

if node[:recipes].include?("accounts::ldap")
  include_recipe "accounts::ldap"
end

if node[:recipes].include?("accounts::autodir")
  include_recipe "accounts::autodir"
end

if node[:recipes].include?("accounts::sudoers")
  include_recipe "accounts::sudoers"
end

if node[:recipes].include?("accounts::pki")
  include_recipe "accounts::pki"
end
