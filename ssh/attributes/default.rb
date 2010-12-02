
node.default[:components][:ssh][:server][:enabled] = true 
node.default[:components][:ssh][:server][:root] = true  
node.default[:components][:ssh][:server][:auth] = ['password', 'publickey']
node.default[:components][:ssh][:server][:port] = 22
node.default[:components][:ssh][:server][:denyhosts] = true 
node.default[:components][:ssh][:server][:allowusers] = []
