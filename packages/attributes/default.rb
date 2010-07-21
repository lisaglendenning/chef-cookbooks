case node[:platform]
when 'redhat', 'centos', 'fedora'
  set[:components][:packages][:repodir] = '/etc/yum.repos.d'
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
          :components => "main"),
          )
      }
    }
    default[:components][:packages][:repos][:official] = default_repos
  end
end
