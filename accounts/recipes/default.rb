
rhels = ['redhat', 'centos', 'fedora']
  
node[:components][:accounts][:packages].each { |p|
  package p do
   action :upgrade
  end
}

AUTODIR_CONFDIR = "/etc/default"
AUTODIR_CONFFILE = AUTODIR_CONFDIR + "/autodir"

template AUTODIR_CONFFILE do
  source "autodir.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :autohome => node[:components][:accounts][:autodir][:autohome],
    :autogroup => node[:components][:accounts][:autodir][:autogroup]
  )
end

SUDOERS = '/etc/sudoers'

template SUDOERS do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :admins => node[:components][:accounts][:admins]
  )
end

#
# Services
#

service "nscd" do
  supports :restart => true, :status => true
  action [:enable, :start]
end

service "autodir" do
  supports :restart => true, :status => false
  action [:enable]
  subscribes :restart, resources(:template => AUTODIR_CONFFILE)
end

# Well, at least on Ubuntu 9.10, the autodir (or autofs?) package is broken
# So we need to make sure autofs4 is loaded
# or something...sigh
case node[:platform]
when rhels
  execute "autofsfix" do
    command ""
    user "root"
    action :nothing
  end
else
  execute "autofsfix" do
    command "depmod && modprobe -r autofs && modprobe autofs4"
    user "root"
    action :nothing
    subscribes :run, resources(:template => AUTODIR_CONFFILE)
    notifies :restart, resources(:service => 'autodir')
  end
end

if node[:components][:accounts][:ldap]
  include_recipe "ldap"
end
