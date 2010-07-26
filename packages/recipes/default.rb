
case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  template 'yum.conf' do
    path '/etc/yum.conf'
    source 'yum.conf.erb'
    mode 0644
    owner "root"
    group "root"
  end
  
  node[:components][:packages][:plugins].each { |k,v|
    yum_plugin k do
      plugin k
      action v[:enabled] ? :enable : :disable
    end
  }

  if node[:components][:packages][:plugins][:priorities][:enabled]
    node[:components][:packages][:repos].each { |k,v|
      v[:exclude].delete('priority')
    }
  else
    node[:components][:packages][:repos].each { |k,v|
      if ! v[:exclude].include?('priority')
        v[:exclude] << 'priority'
      end
    }
  end

  # manage repos
  node[:components][:packages][:repos].each { |k,v|
    conffile = "#{node[:components][:packages][:repodir]}/#{k}.repo"
    template k do
      path conffile
      source "repo.erb"
      mode 0644
      owner "root"
      group "root"
      variables(
        :sections => v[:sections],
        :exclude => v[:exclude]
      )
      if node[:components][:packages][:repos][k][:action] != :create
        only_if "[ -f #{conffile} ]"
      end
    end
  }

else
  template 'sources.list' do
    path node[:components][:packages][:repodir] + "/sources.list"
    source "sources.list.erb"
    mode 0644
    owner "root"
    group "root"
    variables(
      :repos => node[:components][:packages][:repos]
    )
  end
end

#
# manage packages after managing repositories
#

node[:components][:packages][:registry].each { |p,v|
  package p do
    action v
  end
}
