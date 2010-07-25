
#
# Packages
#

packages = case node[:platform]
  when 'redhat', 'centos', 'fedora'
    ['nss-ldap'] # FIXME: requires EPEL
  else
    ['auth-client-config', 'libnss-ldap', 'libpam-ldap', 
     'ldap-auth-config', 'ldapscripts', 'autodir']
  end
packages << 'nscd'

packages.each { |p|
  package p do
    action :upgrade
  end
}

#
# name service caching
#

service "nscd" do
  supports :restart => true, :status => true
  action [:enable, :start]
end

LDAP_CONFDIR = "/etc"
LDAP_CONFFILE = LDAP_CONFDIR + "/ldap.conf"
  
template "nss-pam-ldap-conf" do
  path LDAP_CONFFILE
  source "nss_pam_ldap.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables(
    :client => node[:components][:ldap][:client],
    :accounts => node[:components][:accounts][:ldap]
  )
end

# Packages needed for ldap-password
packages = case node[:platform]
when 'redhat', 'centos', 'fedora'
  ['apg', 'python-ldap', 'cracklib', 'cracklib-dicts']
else
  ['apg', 'python-ldap', 'libcrack2', 'python-cracklib']
end
packages.each { |p|
  package p do
    action :upgrade
  end  
}

#
# Front-end user script for changing LDAP password
#

template "ldap-password" do
  path '/usr/bin/password'
  source "ldap.password.py.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :protocol => node[:components][:accounts][:ldap][:protocol] ? node[:components][:accounts][:ldap][:protocol] : node[:components][:ldap][:client][:protocol],
    :domain => node[:components][:accounts][:ldap][:protocol] ? node[:components][:accounts][:ldap][:domain] : node[:components][:ldap][:client][:domain],
    :basedn => node[:components][:accounts][:ldap][:basedn]
  )
end

#
# modify  system files to allow LDAP authentication
#

case node[:platform]
when 'redhat', 'centos', 'fedora'
  opts = ['--enableldap', '--enableldapauth',
          '--enableshadow', '--enablemd5',
          '--enablecache', '--enablelocauthorize'].join(' ')
  execute "auth-client" do
    command "authconfig #{opts} --update"
    user "root"
    action :nothing
    subscribes :run, resources(:template => "nss-pam-ldap-conf")
  end
else
  execute "auth-client" do
    command "auth-client-config -t nss -p lac_ldap"
    user "root"
    action :nothing
    subscribes :run, resources(:template => "nss-pam-ldap-conf")
    notifies :restart, resources(:service => 'nscd'), :delayed
  end
  execute "pam-auth-update" do
    command "pam-auth-update --package"
    user "root"
    action :nothing
    subscribes :run, resources(:execute => 'auth-client')
    if node.components.attribute?(:ssh)
      notifies :restart, resources(:service => 'sshd'), :delayed
    end
  end
end
