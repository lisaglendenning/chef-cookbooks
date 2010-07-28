
include_recipe "packages"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  # create mach user
  machuser = node[:components][:packages][:build][:user]
  user machuser do
    comment "mach user"
    gid "mach"
    home "/home/#{machuser}"
    shell "/bin/bash"
    system true
  end
  
  # create mach group
  group "mach" do
    members ['root', machuser]
  end

  file "#{machuser}-profile" do
    path "/home/#{machuser}/.bashrc"
    content "umask 0002\n"
    owner machuser
    group "mach"
    mode 0644
  end

  template "machrc" do
    source 'machrc.erb'
    path "/home/#{machuser}/.machrc"
    content "umask 0002\n"
    owner machuser
    group "mach"
    mode 0644
    variables(:mach => node[:components][:packages][:build])
  end
  
  root = node[:components][:packages][:build][:root]
  file "rpmmacros" do
    path "/root/.rpmmacros"
    owner "root"
    group "root"
    mode 0644
    content "%_topdir #{root}\n"
  end

  # create rpmbuild directories
  [root, "#{root}/BUILD", "#{root}/RPMS", "#{root}/SOURCES", "#{root}/SPECS", "#{root}/SRPMS"].each { |d|
    directory d do
      owner machuser
      group "mach"
      mode 0770
    end
  }
  
  if node.components.packages.build.attribute?(:registry)
    # setup mach roots if required
    cmd = "cat /etc/mach/conf | grep \"config\\['defaultroot'\\]\" | cut -d \"=\" -f 2 | sed \"s/[ \t\n',]//g\""
    defaultroot = `#{cmd}`
    roots = []
    node[:components][:packages][:build][:registry].each { |k,v|
      target = defaultroot
      if v.key?(:root) && !v[:root].nil?
        target = v[:root]
      end
      if ! roots.include?(target)
        roots << target
      end
    }
    
    cmd = "cat /etc/mach/conf | grep \"'roots':\" | cut -d \":\" -f 2 | sed \"s/[ \t\n',]//g\""
    rootspath = `#{cmd}`
    roots.each { |r|
      if ! File::exists?("#{rootspath}/#{r}")
        cmd = "sudo -u #{machuser} -i \"mach"
        if r != defaultroot
          cmd << " -r #{r}" 
        end
        cmd << " setup build\""
        outs = `#{cmd} 2>&1`
        if $?.to_i != 0:
          raise RuntimeError, outs
      end
    }
  end

end
