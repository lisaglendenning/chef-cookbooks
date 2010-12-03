
include_recipe "accounts"


SUDOERS = '/etc/sudoers'

sudoers = ["%#{node[:components][:accounts][:sudoers][:group]}"]

template "sudoers" do
  path SUDOERS
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers => sudoers
  )
end

# match admins to user/group databags

sudoers = []
users = data_bag_item('accounts', 'users')
groups = data_bag_item('accounts', 'groups')
node[:components][:accounts][:sudoers][:users].each { |admin|
  admin = admin.to_s
  if users.key?(admin) 
    if (`getent passwd #{admin}`).length > 0
      sudoers << admin
    else
      raise RuntimeError, "invalid user: #{admin}"
    end
  elsif groups.key?(admin) # assume admin is a group
    group['users'].each { |u|
      if (`getent passwd #{u}`).length > 0
        sudoers << u
      end
    }
  else
    raise RuntimeError, "invalid user or group: #{admin}"
  end
}

group 'sudoers' do
  group_name node[:components][:accounts][:sudoers][:group]
  action :create
  members sudoers
  append true
end
