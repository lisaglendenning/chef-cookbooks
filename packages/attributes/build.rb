
include_attribute "packages"

if node[:components][:packages][:builder]
  case node[:platform]
  when 'redhat', 'centos', 'fedora'
    if node[:platform] == 'centos'
      # FIXME: requires EPEL
      node.set[:components][:packages][:registry][:mach][:action] = :install
    end
  
    node.default[:components][:packages][:build][:user] = 'mach'
    node.default[:components][:packages][:build][:group] = 'mach'
    node.default[:components][:packages][:build][:vendor] = node[:domain]
    node.default[:components][:packages][:build][:packager] = "root@#{node[:components][:packages][:build][:vendor]}" 
  
  # TODO: else
  end
end
