
case node[:platform]
when 'redhat', 'centos', 'fedora'
  node.set[:components][:packages][:repodir] = '/etc/yum.repos.d'
  
  node.default[:components][:packages][:plugins][:priorities][:enabled] = true
  if node[:components][:packages][:plugins][:priorities][:enabled]
    node.set[:components][:packages][:registry]['yum-priorities'][:action] = :install
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
     [:updates, 'Updates', 'updates-newkey'],
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
  elsif node[:platform] == 'fedora'

    #
    # Fedora Base
    #   
    
    mirrorurl = "http://mirrors.fedoraproject.org/"
    baseurl = "http://download.fedora.redhat.com/pub/fedora/linux/"

    case node[:platform_version][0,1]
    when '8', '9'
      node.default[:components][:packages][:repos]['fedora'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora', 
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY']
    else
      node.default[:components][:packages][:repos]['fedora'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch']
    end
    keys = node.default[:components][:packages][:repos]['fedora'][:keys]
        
    node.default[:components][:packages][:repos]['fedora'][:official] = true
    node.default[:components][:packages][:repos]['fedora'][:exclude] = ['baseurl']
      
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:name] = "Fedora $releasever - $basearch"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=fedora-$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:baseurl] = "#{baseurl}releases/$releasever/Everything/$basearch/os/"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:enabled] = "1"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora'][:failovermethod] = "priority"
      
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:name] = "Fedora $releasever - $basearch - Debug"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=fedora-debug-$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:baseurl] = "#{baseurl}releases/$releasever/Everything/$basearch/debug/"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-debuginfo'][:failovermethod] = "priority"

    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:name] = "Fedora $releasever - Source"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=fedora-source-$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:baseurl] = "#{baseurl}releases/$releasever/Everything/source/SRPMS/"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora'][:sections]['fedora-source'][:failovermethod] = "priority"

    #
    # Fedora Updates
    #   
      
    case node[:platform_version][0,1]
    when '8', '9'
      node.default[:components][:packages][:repos]['fedora-updates'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora']
    else
      node.default[:components][:packages][:repos]['fedora-updates'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch']
    end
    keys = node.default[:components][:packages][:repos]['fedora-updates'][:keys]
    node.default[:components][:packages][:repos]['fedora-updates'][:official] = true
    node.default[:components][:packages][:repos]['fedora-updates'][:exclude] = ['baseurl']

    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:name] = "Fedora $releasever - $basearch - Updates"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:baseurl] = "#{baseurl}updates/$releasever/$basearch/"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:gpgkey] = keys.join(' ')
    case node[:platform_version][0,1]
    when '8', '9'
      # I think that all of the updates have been released in newkey, so we can disable this ?
      node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:enabled] = "0"
    else
      node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:enabled] = "1"
    end
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates'][:failovermethod] = "priority"  

    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:name] = "Fedora $releasever - $basearch - Updates Debug"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-debug-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:baseurl] = "#{baseurl}updates/$releasever/$basearch/debug/"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-debuginfo'][:failovermethod] = "priority"  

    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:name] = "Fedora $releasever - Updates Source"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-source-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:baseurl] = "#{baseurl}updates/$releasever/SRPMS/"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora-updates'][:sections]['updates-source'][:failovermethod] = "priority"  

    #
    # Fedora Testing
    #   
      
    case node[:platform_version][0,1]
    when '8', '9'
      node.default[:components][:packages][:repos]['fedora-updates-testing'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-test']
    else
      node.default[:components][:packages][:repos]['fedora-updates-testing'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch']
    end
    keys = node.default[:components][:packages][:repos]['fedora-updates-testing'][:keys]
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:official] = true
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:exclude] = ['baseurl']
    
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:name] = "Fedora $releasever - $basearch - Test Updates"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:baseurl] = "#{baseurl}updates/testing/$releasever/$basearch/"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing'][:failovermethod] = "priority"  
    
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:name] = "Fedora $releasever - $basearch - Test Updates Debug"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-debug-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:baseurl] = "#{baseurl}updates/testing/$releasever/$basearch/debug/"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-debuginfo'][:failovermethod] = "priority"  
    
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:name] = "Fedora $releasever - $basearch - Test Updates Source"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-source-f$releasever&arch=$basearch"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:baseurl] = "#{baseurl}updates/testing/$releasever/SRPMS/"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:gpgcheck] = "1"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:gpgkey] = keys.join(' ')
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:enabled] = "0"
    node.default[:components][:packages][:repos]['fedora-updates-testing'][:sections]['updates-testing-source'][:failovermethod] = "priority"  

    #
    # Fedora Unstable
    #   
    

    case node[:platform_version][0,1]
    when '8', '9'
      node.default[:components][:packages][:repos]['fedora-development'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-test', 
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora']
      keys = node.default[:components][:packages][:repos]['fedora-development'][:keys]
      node.default[:components][:packages][:repos]['fedora-development'][:official] = true
      node.default[:components][:packages][:repos]['fedora-development'][:exclude] = ['baseurl']
      
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:name] = "Fedora - Development"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=rawhide&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:baseurl] = "#{baseurl}development/$basearch/os/"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:name] = "Fedora - Development - Debug"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=rawhide-debug&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:baseurl] = "#{baseurl}development/$basearch/debug/"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-debuginfo'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:name] = "Fedora - Development - Source"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=rawhide-source&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:baseurl] = "#{baseurl}development/source/SRPMS/"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-development'][:sections]['development-source'][:failovermethod] = "priority"  

    else
      node.default[:components][:packages][:repos]['fedora-rawhide'][:keys] = [
        'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$basearch']
      keys = node.default[:components][:packages][:repos]['fedora-rawhide'][:keys]
      node.default[:components][:packages][:repos]['fedora-rawhide'][:official] = true
      node.default[:components][:packages][:repos]['fedora-rawhide'][:exclude] = ['baseurl']
      
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:name] = "Fedora - Rawhide - Developmental packages for the next Fedora release"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:mirrorlist] = "#{mirrorurl}metalink?repo=rawhide&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:baseurl] = "#{baseurl}development/$basearch/os/"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:name] = "Fedora - Rawhide -  Debug"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:mirrorlist] = "#{mirrorurl}metalink?repo=rawhide-debug&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:baseurl] = "#{baseurl}development/$basearch/debug/"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-debuginfo'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:name] = "Fedora - Rawhide - Source"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:mirrorlist] = "#{mirrorurl}metalink?repo=rawhide-source&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:baseurl] = "#{baseurl}development/source/SRPMS/"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:gpgcheck] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-rawhide'][:sections]['rawhide-source'][:failovermethod] = "priority"  
    end
    
    case node[:platform_version][0,1]
    when '8', '9'
      # Fedora 8 and 9 had a compromised package key
      # http://fedoraproject.org/wiki/Enabling_new_signing_key

      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:keys] = ['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-8-and-9']
      keys = node.default[:components][:packages][:repos]['fedora-updates-newkey'][:keys]
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:official] = true
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:exclude] = ['baseurl']
      
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:name] = "Fedora $releasever - $basearch - Updates NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:baseurl] = "#{baseurl}updates/$releasever/$basearch.newkey/"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:enabled] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-newkey'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:name] = "Fedora $releasever - $basearch - Updates - Debug NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-debug-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:baseurl] = "#{baseurl}updates/$releasever/$basearch.newkey/debug/"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-debuginfo-newkey'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:name] = "Fedora $releasever - $basearch - Updates Source NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-released-source-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:baseurl] = "#{baseurl}updates/$releasever/SRPMS.newkey/"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-updates-newkey'][:sections]['updates-source-newkey'][:failovermethod] = "priority"  

      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:keys] = ['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-test-8-and-9']
      keys = node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:keys]
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:official] = true
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:exclude] = ['baseurl']
      
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:name] = "Fedora $releasever - $basearch - Test Updates NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:baseurl] = "#{baseurl}updates/testing/$releasever/$basearch.newkey/"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:name] = "Fedora $releasever - $basearch - Test Updates Debug NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-newkey-debug-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:baseurl] = "#{baseurl}updates/testing/$releasever/$basearch.newkey/debug/"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-debuginfo'][:failovermethod] = "priority"  
      
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:name] = "Fedora $releasever - $basearch - Test Updates Source NewKey"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:mirrorlist] = "#{mirrorurl}mirrorlist?repo=updates-testing-source-f$releasever.newkey&arch=$basearch"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:baseurl] = "#{baseurl}updates/testing/$releasever/SRPMS.newkey/"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:gpgcheck] = "1"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:gpgkey] = keys.join(' ')
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:enabled] = "0"
      node.default[:components][:packages][:repos]['fedora-updates-testing-newkey'][:sections]['updates-testing-newkey-source'][:failovermethod] = "priority" 

    end
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
