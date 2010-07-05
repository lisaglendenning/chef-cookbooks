
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
    :sudoers => node[:components][:accounts][:sudoers]
  )
end

admin_group = case node[:platform]
when rhels
  'wheel'
else
  'admin'
end

# get admin info from databag
admin_users = case node[:platform]
when rhels
  ['root']
else
  []
end
users = data_bag_item('accounts', 'users')['uids']
node[:components][:accounts][:admins].each { |admin|
  admin = admin.to_s
  if users.key?(admin)
    admin_users << admin
  else
    # assume admin is a group
    users.each { |k,v|
      if v['groups'].include?(admin)
        admin_users << k
      end
    }
  end
}

# get ssh public key info from databag
if node[:components].key?(:ssh)
  AUTHFILE = 'authorized_keys'
  users.each { |name, props|
    user_info = `getent passwd #{name}`
    if ! user_info.empty?
      authkeys = props['pki']['authorized']
      authkeys = authkeys.join('\n') + '\n'
      user_info = user_info.split(':')
      dotssh = "#{user_info[5]}/.ssh"
      file "#{user_info[0]}-dotssh-authkeys" do
        path "#{dotssh}/#{AUTHFILE}"
        owner user_info[0]
        group user_info[3]
        mode "0600"
        content authkeys
        action :create
        not_if "[ ! -d #{dotssh} ]"
      end
      directory "#{user_info[0]}-dotssh" do
        path dotssh
        owner user_info[0]
        group user_info[3]
        mode "0700"
      end 
    end
  }
end

group 'admin' do
  group_name admin_group
  action :modify
  members admin_users
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

if node[:components][:accounts][:hasldap]
  include_recipe "ldap"
end
