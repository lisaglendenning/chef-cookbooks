
packages = ['autodir']

packages.each { |p|
  package p do
    action :upgrade
  end
}

case node[:platform]
when 'redhat', 'centos', 'fedora'
  AUTODIR_CONFDIR = "/etc/sysconfig"
  
  services = ['autohome', 'autogroup']
  services.each { |s|
    template "#{s}-conf" do
      path "#{AUTODIR_CONFDIR}/#{s}"
      source "#{s}.erb"
      mode 0644
      owner "root"
      group "root"
    end
    service s do
      supports :restart => true, :status => true
      action node[:components][:accounts][:autodir][s.to_sym] ? [:enable,:start] : [:stop,:disable]
      subscribes :restart, resources(:template => "#{s}-conf")
    end
  }
  
else
  AUTODIR_CONFDIR = "/etc/default"
  AUTODIR_CONFFILE = AUTODIR_CONFDIR + "/autodir"
  
  template "autodir-conf" do
    path AUTODIR_CONFFILE
    source "autodir.erb"
    mode 0644
    owner "root"
    group "root"
    variables(
      :autohome => node[:components][:accounts][:autodir][:autohome],
      :autogroup => node[:components][:accounts][:autodir][:autogroup]
    )
  end
  
  service "autodir" do
    supports :restart => true, :status => false
    action :enable
    subscribes :restart, resources(:template => "autodir-conf")
  end
  
  # Well, at least on Ubuntu 9.10, the autodir (or autofs?) package is broken
  # So we need to make sure autofs4 is loaded
  # or something...sigh
  execute "autofsfix" do
    command "depmod && modprobe -r autofs && modprobe autofs4"
    user "root"
    action :nothing
    subscribes :run, resources(:template => "autodir-conf")
    notifies :restart, resources(:service => 'autodir')
  end
end
