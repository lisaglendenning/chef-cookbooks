

if node[:components][:accounts][:ldap][:enabled]
  include_recipe "accounts::ldap"
end

if node[:components][:accounts][:autodir][:autohome] || node[:components][:accounts][:autodir][:autogroup]
  include_recipe "accounts::autodir"
end


#
# Admins
#

SUDOERS = '/etc/sudoers'

template "sudoers" do
  path SUDOERS
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers => node[:components][:accounts][:sudoers]
  )
end

admin_group = case node[:platform]
when 'redhat', 'centos', 'fedora'
  'wheel'
else
  'admin'
end

# get admin info from databag
admin_users = []
users = data_bag_item('accounts', 'users')['uids']
node[:components][:accounts][:admins].each { |admin|
  admin = admin.to_s
  if users.key?(admin) && (`getent passwd #{admin}`).length > 0
    admin_users << admin
  else
    # assume admin is a group
    users.each { |k,v|
      if v['groups'].include?(admin) && (`getent passwd #{k}`).length > 0
        admin_users << k
      end
    }
  end
}

group 'admin' do
  group_name admin_group
  action :create
  members admin_users
  append true
end

#
# Populate SSH authorized keys
#

if node.components.attribute?(:ssh)
  AUTHFILE = 'authorized_keys'
  users.each { |name, props|
    user_info = `getent passwd #{name}`
    if ! user_info.empty? && props.key?('pki') && props['pki'].key?('authorized')
      authkeys = props['pki']['authorized']
      user_info = user_info.split(':')
      dotssh = "#{user_info[5]}/.ssh"
      file "#{user_info[0]}-dotssh-authkeys" do
        path "#{dotssh}/#{AUTHFILE}"
        owner user_info[0]
        group user_info[3]
        mode "0600"
        content authkeys.join("\n") + "\n"
        action :create
        not_if "[ ! -d #{dotssh} ]"
      end
      directory "#{user_info[0]}-dotssh" do
        path dotssh
        owner user_info[0]
        group user_info[3]
        mode "0700"
        not_if "[ ! -d #{user_info[5]} ]"
        notifies :create, resources(:file => "#{user_info[0]}-dotssh-authkeys")
      end 
    end
  }
end
