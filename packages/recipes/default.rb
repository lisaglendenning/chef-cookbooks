
[node[:components][:packages][:repos], node[:components][:packages][:plugins]].each { |x|
  x.each { |k,v|
    if v.key?(:package)
      if ! node[:components][:packages][:packages].include?(v[:package])
        node[:components][:packages][:packages] << v[:package]
      end
    end
  }
}

node[:components][:packages][:packages].each { |p|
  package p do
    action :upgrade
  end
}

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
      plugin v[:plugin]
      action v[:action]
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
      only_if "[ -f #{conffile} ]"
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
