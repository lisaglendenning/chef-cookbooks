
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

  # parse existing repo files for default values
  repofiles = []
  repodir = node[:components][:packages][:repodir]
  Dir.entries(repodir).each { |f|
    if f[-5..-1] == '.repo'
      repofiles << f
    end
  }
  repofiles.each { |fname|
    reponame = fname[0..-6]
    node.default[:components][:packages][:repos][reponame][:official] = false
    node.default[:components][:packages][:repos][reponame][:exclude] = []
    f = File.new("#{repodir}/#{fname}", "r")
    section = nil  
    k = nil
    v = nil
    f.each_line do |line|
      tokens = [line.strip, nil]
      content = 0
      if tokens[content].index('#')
        tokens = tokens[content].split(/\s*#\s*/, 1)
      end
      if ! tokens[content].empty?
        if tokens[content] =~ /^\[(.+)\]/
          section = $1.strip
        elsif tokens[content] =~ /^(.+?)\s*=\s*(.+)/
          if k && v
            # store the previous value
            node.default[:components][:packages][:repos][reponame][:sections][section][k] = v
          end
          k = $1.strip
          v = $2.strip
        else # must be a value continuation
          v << line
        end
      end
    end
    if k && v
      # store the last value
      node.default[:components][:packages][:repos][reponame][:sections][section][k] = v
    end
    node.default[:components][:packages][:repos][reponame][:sections][:priority] = 5
    f.close
  }

  if ! node[:components][:packages][:plugins].key?(:priorities)
    node[:components][:packages][:repos].each { |k,v|
      if ! v[:exclude].include?('priority')
        v[:exclude] << 'priority'
      end
    }
  else
    node[:components][:packages][:repos].each { |k,v|
      v[:exclude].delete('priority')
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
      :repos => node[:components][:packages][:repos][:official]
    )
  end
end
