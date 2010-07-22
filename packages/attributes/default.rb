case node[:platform]
when 'redhat', 'centos', 'fedora'
  set[:components][:packages][:repodir] = '/etc/yum.repos.d'
    
  if node[:platform] == 'centos'
    release = 'CentOS-5'
    
    base_repo = Mash.new
    [['base', 'Base', 'os'], 
     ['updates', 'Updates', 'updates'],
     ['addons', 'Addons', 'addons'],
     ['extras', 'Extras', 'extras'],
     ['centosplus', 'Plus', 'centosplus'],
     ['contrib', 'Contrib', 'contrib']].each { |r|
      base_repo[r[0]] = Mash.new( 
        :name => "CentOS-$releasever - #{r[1]}",
        :mirrorlist => "http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=#{r[2]}",
        #:baseurl => "http://mirror.centos.org/centos/$releasever/#{r[2]}/$basearch/"
        :gpgcheck => "1",
        :gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}",
        :enabled => "1"
      )
    }
    
    media_repo = Mash.new
    media_repo['c5-media'] = Mash.new(
      :name => "CentOS-$releasever - Media",
      :baseurl => "file:///media/CentOS/\nfile:///media/cdrom/\nfile:///media/cdrecorder/",
      :gpgcheck => "1",
      :gpgkey => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-#{release}",
      :enabled => "0"
      ) 

    default[:components][:packages][:repos][:official]['CentOS-Base'] = base_repo 
    default[:components][:packages][:repos][:official]['CentOS-Media'] = media_repo
    
    default[:components][:packages][:repos][:extra] = Mash.new
  end
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
    default[:components][:packages][:repos][:official] = default_repos
  end
end
