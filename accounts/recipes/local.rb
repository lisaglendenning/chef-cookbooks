
include_recipe "accounts"

# ruby-shadow library needs to be installed

case node[:platform]
when 'redhat', 'centos', 'fedora'
  package 'ruby-shadow' do
    action :upgrade
  end
# the package for debian is libshadow-ruby1.8
end

local = data_bag_item('accounts', 'local')
local['users'].each { |k,v|
  user k do
    action :create
    comment v.key?('comment') ? v['comment'] : nil
    uid v.key?('uid') ? v['uid'] : nil
    gid v.key?('gid') ? v['gid'] : nil
    home v.key?('home') ? v['home'] : nil
    shell v.key?('shell') ? v['shell'] : nil
    password v.key?('password') ? v['password'] : nil
  end
}
