
include_attribute "accounts"

if node.recipes.include?("accounts::autodir")
  node.default[:components][:accounts][:autodir][:autohome] = true
  node.default[:components][:accounts][:autodir][:autogroup] = false
end
