
include_attribute "packages"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  if node[:platform] == 'centos'
    # FIXME: requires EPEL
    # for building RPMs
    node.set[:components][:packages][:registry][:mach] = :install
  end

  node.default[:components][:packages][:build][:user] = 'mach'
  node.default[:components][:packages][:build][:root] = '/home/mach'

# TODO: else
end
