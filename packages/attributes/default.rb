
node.default[:components][:packages][:packages] = []

case node[:platform]
when 'redhat', 'centos', 'fedora'
  node.set[:components][:packages][:repodir] = '/etc/yum.repos.d'
  
  node.default[:components][:packages][:plugins][:priorities][:package] = 'yum-priorities'
  node.default[:components][:packages][:plugins][:priorities][:enabled] = true
      
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
      if ! tokens[content].index('#').nil?
        tokens = tokens[content].split(/\s*#\s*/, 2)
      end
      if ! tokens[content].empty?
        if tokens[content] =~ /^\[(.+)\]/
          if section
            node.default[:components][:packages][:repos][reponame][:sections][section][:priority] = 5
          end
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
    if section
      node.default[:components][:packages][:repos][reponame][:sections][section][:priority] = 5
    end
    if k && v
      # store the last value
      node.default[:components][:packages][:repos][reponame][:sections][section][k] = v
    end
    f.close
  }

  # this section overrides the previous section
  if node[:platform] == 'centos'
  
    release = "CentOS-#{node[:platform_version][0,1]}"
  
    node.default[:components][:packages][:repos]['CentOS-Base'][:official] = true
    node.default[:components][:packages][:repos]['CentOS-Base'][:exclude] = ['baseurl']
    [[:base, 'Base', 'os'], 
     [:updates, 'Updates', 'updates'],
     [:addons, 'Addons', 'addons'],
     [:extras, 'Extras', 'extras'],
     [:centosplus, 'Plus', 'centosplus'],
     [:contrib, 'Contrib', 'contrib']].each { |r|
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:name] = "CentOS-$releasever - #{r[1]}"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:mirrorlist] = "http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=#{r[2]}"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:baseurl] = "http://mirror.centos.org/centos/$releasever/#{r[2]}/$basearch/"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:gpgkey] = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:enabled] = (r[0] == :contrib || r[0] == :centosplus) ? "0" : "1"
      node.default[:components][:packages][:repos]['CentOS-Base'][:sections][r[0]][:priority] = (r[0] == :contrib || r[0] == :centosplus) ? "2" : "1"
    }
  
    node.default[:components][:packages][:repos]['CentOS-Media'][:official] = true
    node.default[:components][:packages][:repos]['CentOS-Media'][:exclude] = []
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:name] = "CentOS-$releasever - Media"
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:baseurl] = "file:///media/CentOS/\nfile:///media/cdrom/\nfile:///media/cdrecorder/"
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:gpgkey] = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}"
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:enabled] = "0"
    node.default[:components][:packages][:repos]['CentOS-Media'][:sections]['c5-media'][:priority] = "2"
  
  end

else
  node.set[:components][:packages][:repodir] = '/etc/apt'
  
  if node[:platform] == 'debian'
    dist = "lenny"
    default_repos = []
    [{:url => "http://ftp.us.debian.org/debian/", :dist => "#{dist}"},
     {:url => "http://security.debian.org/", :dist => "#{dist}/updates"},
     {:url => "http://volatile.debian.org/debian-volatile", :dist => "#{dist}/volatile"}].each { |repo|
      ["deb", "deb-src"].each { |c|
        default_repos << Mash.new(
          :command => c, 
          :url => repo[:url],
          :distribution => repo[:dist],
          :components => "main")
      }
    }
    node.default[:components][:packages][:repos][:debian] = default_repos
  end
end
