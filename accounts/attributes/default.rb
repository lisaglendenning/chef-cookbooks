
node.default[:components][:accounts][:admins] = []
node.default[:components][:accounts][:sudoers] = case node[:platform]
when 'redhat', 'centos', 'fedora'
  ['%wheel']
else
  ['%admin']
end
