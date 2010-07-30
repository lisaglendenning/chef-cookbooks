
include_recipe "packages"

#
# Hudson user
#

hudsonuser = node[:components][:hudson][:user]
hudsongroup = node[:components][:hudson][:group]

user hudsonuser do
  comment "hudson user"
  home "/home/#{hudsonuser}"
  shell "/bin/bash"
  system true
end
group hudsongroup do
  members [hudsonuser]
  append true
end

#
# Hudson control files
#

hudsonhome = node[:components][:hudson][:home]

directory hudsonhome do
  path hudsonhome
  owner hudsonuser
  group hudsongroup
  mode 0755
end

cookbook_file "hudson-server" do
  path "#{hudsonhome}/hudson-server"
  owner hudsonuser
  group hudsonuser
  mode 0755
  source "hudson-server"
end

template "hudson-service" do
  source "hudson.erb"
  path "/etc/rc.d/init.d/hudson"
  owner "root"
  group "root"
  mode 0755
  variables(:hudson => node[:components][:hudson])
end

#
# Hudson source
#

hudsonfile = node[:components][:hudson][:download][/[^\/]+$/]

remote_file hudsonfile do
  source node[:components][:hudson][:download]
  path "#{hudsonhome}/#{hudsonfile}"
  owner hudsonuser
  group hudsongroup
  mode 0755
end

#
# Hudson service
#

service 'hudson' do
  supports :restart => true, :status => true
  action [:enable, :start]
end
