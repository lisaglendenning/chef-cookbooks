
include_attribute "accounts"

node.default[:components][:accounts][:autodir][:autohome] = true
node.default[:components][:accounts][:autodir][:autogroup] = false
