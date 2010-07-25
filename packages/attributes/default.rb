
default[:components][:packages][:repos] = Mash.new
default[:components][:packages][:packages] = []

case node[:platform]
when 'redhat', 'centos', 'fedora'
  set[:components][:packages][:repodir] = '/etc/yum.repos.d'
  
  priority_plugin = Mash.new(:plugin => 'priorities', :package => 'yum-priorities', :action => :enable)
  default[:components][:packages][:plugins][:priorities] = priority_plugin
      
  if node[:platform] == 'centos'

    release = "CentOS-#{node[:platform_version][0,1]}"
    
    if ! components[:packages][:repos].key?('CentOS-Base')
      base_sections = Mash.new
      [['base', 'Base', 'os'], 
       ['updates', 'Updates', 'updates'],
       ['addons', 'Addons', 'addons'],
       ['extras', 'Extras', 'extras'],
       ['centosplus', 'Plus', 'centosplus'],
       ['contrib', 'Contrib', 'contrib']].each { |r|
        base_sections[r[0]] = Mash.new( 
          :name => "CentOS-$releasever - #{r[1]}",
          :mirrorlist => "http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=#{r[2]}",
          :baseurl => "http://mirror.centos.org/centos/$releasever/#{r[2]}/$basearch/",
          :gpgcheck => "1",
          :gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}",
          :enabled => (r[0] == 'contrib' || r[0] == 'centosplus') ? "0" : "1",
          :priority => (r[0] == 'contrib' || r[0] == 'centosplus') ? "2" : "1"
        )
      }
      base_repo = Mash.new
      base_repo[:official] = true
      base_repo[:exclude] = ['baseurl']
      base_repo[:sections] = base_sections
      set[:components][:packages][:repos]['CentOS-Base'] = base_repo
    end

    if ! components[:packages][:repos].key?('CentOS-Media')
      media_sections = Mash.new
      media_sections['c5-media'] = Mash.new(
        :name => "CentOS-$releasever - Media",
        :baseurl => "file:///media/CentOS/\nfile:///media/cdrom/\nfile:///media/cdrecorder/",
        :gpgcheck => "1",
        :gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}",
        :enabled => "0",
        :priority => "2"
      ) 
      media_repo = Mash.new
      media_repo[:official] = true
      media_repo[:exclude] = []
      media_repo[:sections] = media_sections
      set[:components][:packages][:repos]['CentOS-Media'] = media_repo
    end
  end
  
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
    node.default[:components][:packages][:repos][reponame][:sections] = Mash.new
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

else
  set[:components][:packages][:repodir] = '/etc/apt'
  
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
    default[:components][:packages][:repos][:debian] = default_repos
  end
end
