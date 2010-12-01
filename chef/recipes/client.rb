
chef_version = node[:chef_packages][:chef][:version]
chef_version = chef_version.split('.')
chef_version = chef_version[0, 2].join('.')

if node[:components][:chef][:client][:enabled]
  
  if node[:components][:chef][:install] == :package
    package 'chef' do
      action :upgrade
    end
  end
  
  template "chef-client-config" do
    path node[:components][:chef][:client][:config]
    source "client.#{chef_version}.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :client => node[:components][:chef][:client]
    )
  end
  
  if node[:components][:chef][:client][:daemon]
    service "chef-client" do
      supports :restart => true, :status => true
      action [ :enable, :start ]
      only_if "[ -f #{node[:components][:chef][:client][:config]} ]"
    end
  end
  
  template "chef-client-config-service" do
    path node[:components][:chef][:client][:service_config]
    source "chef-client.#{chef_version}.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :client => node[:components][:chef][:client]
    )
  end
  
  if not node[:components][:chef][:server][:enabled]
    # remove the validation key once we have a client key
    valkey = node[:components][:chef][:client][:validator_key]
    clikey = node[:components][:chef][:client][:client_key]
    execute "remove-validation" do
      command "if [ -f #{valkey} ]; then rm -f #{valkey}; fi"
      only_if "[[ (-f #{clikey}) && (-f #{valkey}) ]]"
      action :run
    end
  end
  
  # hack to destroy zombie chef processes
  # IMPORTANT: turn this off if you have a reason to run multiple clients!
  if node[:components][:chef][:client][:daemon]
    PIDFILE = '/var/run/chef/client.pid'
    ruby_block "clean-chef-client" do
      block do
        pid = `cat #{PIDFILE}`
        procs = `ps -C chef-client -o pid=`
        pids = procs.split(' ')
        pids.each { |p|
          if p != pid
            Process.kill("SIGINT", Integer(p))
          end
        }
      end
      only_if "[ -f #{PIDFILE} ]"
    end
  end
  
end
