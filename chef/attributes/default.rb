
node.default[:components][:chef][:install] = :package
node.default[:components][:chef][:client][:enabled] = true
node.default[:components][:chef][:server][:enabled] = false
node.default[:components][:chef][:webui][:enabled] = false
