
case node[:platform]
when 'redhat', 'centos', 'fedora'
  # Requires EPEL
  package 'daemonize' do
    action :upgrade
  end
end

service_dir = case node[:platform]
when 'redhat', 'centos', 'fedora'
  '/etc/rc.d/init.d'
end

if node.components.daemon.attribute?(:registry)
  node[:components][:daemon][:registry].each { |name,props|
    
    # user/group
    
    if `getent passwd #{props[:user]}`.length == 0
      user props[:user] do
        system true
        shell '/bin/false'
      end
    end
    if not props.key?(:group)
      props[:group] = props[:user]
    end
    group props[:group] do
      members [props[:user]]
      append true    
    end
    
    
    # init script
  
    template "daemon-#{name}" do
      path "#{service_dir}/#{name}"
      source "service.sh.erb"
      mode 0755
      owner "root"
      group "root"
      variables(
        :name => name,
        :service => props
      )
    end
  
    # service

    service name do
      supports :restart => true, :status =>true
      action [:enable, :start]
    end
  }
end
