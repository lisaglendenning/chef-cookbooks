include_attributes "accounts"

node.default[:components][:accounts][:sudoers][:users] = []
node.default[:components][:accounts][:sudoers][:group] = case node[:platform]
when 'redhat', 'centos', 'fedora'
  'wheel'
else
  'admin'
end
