
node.default[:components][:ssh][:server][:enabled] = true 
node.default[:components][:ssh][:server][:root] = true  
node.default[:components][:ssh][:server][:auth] = ['password', 'publickey']

node.default[:components][:ssh][:packages] = case node[:platform]
  when 'redhat', 'centos', 'fedora'
    ['openssh-clients', 'openssh',  'openssh-server', 'denyhosts']
  else
    ['openssh-client', 'openssh-server', 'denyhosts']
  end  

node.default[:components][:ssh][:server][:port] = 22
