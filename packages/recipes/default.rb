
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
      if v.key?(:exclude)
        v[:exclude].delete('priority')
      end
    }
  else
    node[:components][:packages][:repos].each { |k,v|
      if v.key?(:exclude) && !v[:exclude].include?('priority')
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
        :exclude => v[:exclude] ? v[:exclude] : []
      )
      if v[:action] != 'create'
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

if node.components.packages.attribute?(:registry)
  node[:components][:packages][:registry].each { |p,v|
    act = v.key?(:action) ? v[:action] : :install
    if v.key?(:url)
      f = v[:url][/[^\/]+$/]
      source = "/tmp/#{f}"
      package p do
        source source
        only_if "[ -f #{source} ]"
        action :nothing
      end
      remote_file source do
        path source
        source v[:url]
        if v.key?(:checksum)
          checksum v[:checksum]
        end
        notifies action, resources(:package => p), :immediately
      end
    else
      package p do
        action act
      end
    end 
  }
end
