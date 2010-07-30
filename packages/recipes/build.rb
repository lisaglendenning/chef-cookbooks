
include_recipe "packages"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  # create mach user
  machuser = node[:components][:packages][:build][:user]
  machgroup = node[:components][:packages][:build][:group]
  user machuser do
    comment "mach user"
    gid machgroup
    home "/home/#{machuser}"
    shell "/bin/bash"
    system true
  end
  
  # create mach group
  group machgroup do
    members ['root', machuser]
  end

  file "#{machuser}-profile" do
    path "/home/#{machuser}/.bashrc"
    content "umask 0002\n"
    owner machuser
    group machgroup
    mode 0644
  end

  template "machrc" do
    source 'machrc.erb'
    path "/home/#{machuser}/.machrc"
    content "umask 0002\n"
    owner machuser
    group machgroup
    mode 0644
    variables(:mach => node[:components][:packages][:build])
  end

  if node.components.packages.build.attribute?(:registry)
    # setup mach roots if required
    cmd = "grep \"config\\['defaultroot'\\]\" /etc/mach/conf | cut -d \"=\" -f 2 | sed \"s/[',]//g\""
    defaultroot = `#{cmd}`
    defaultroot = defaultroot.strip
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
    
    cmd = "grep \"'roots':\" /etc/mach/conf | cut -d \":\" -f 2 | sed \"s/[',]//g\""
    rootspath = `#{cmd}`
    rootspath = rootspath.strip
    roots.each { |r|
      ruby_block "mach-setup-#{r}" do
        block do
          cmd = "su --login --command=\"mach"
          if r != defaultroot
            cmd << " -r #{r}" 
          end
          cmd << " setup build\" #{machuser}"
          outs = `#{cmd} 2>&1`
          if $?.to_i != 0:
            raise RuntimeError, outs
          end
        end
        not_if "[ -d #{rootspath}/#{r} ]" 
      end
    }
    
    # where built RPMs go
    cmd = "grep \"'results':\" /etc/mach/conf | cut -d \":\" -f 2 | sed \"s/[',]//g\""
    resultspath = `#{cmd}`
    resultspath = resultspath.strip
        
    # build rpms
    node[:components][:packages][:build][:registry].each { |k,v|
      specfile = v.key?(:cookbook) ? "/tmp/#{v[:spec]}" : v[:spec]
      root = (v.key?(:root) && !v[:root].nil?) ? v[:root] : nil

      ruby_block "mach-build-#{k}" do
        block do
          cmd = "su --login --command=\"mach"
          if root
            cmd << " -r #{root}" 
          end
          cmd << " build #{specfile}\" #{machuser}"
          outs = `#{cmd} 2>&1`
          if $?.to_i != 0:
            raise RuntimeError, outs
          end
        end
        action :nothing
      end
      
      if v.key?(:cookbook)
        cookbook_file v[:spec] do
          path specfile
          source v[:spec]
          owner machuser
          group "mach"
          mode 0644
          cookbook v[:cookbook]
          notifies :create, resources(:ruby_block => "mach-build-#{k}"), :immediately
        end
      end
      
      if v[:action] == :install
        rpmroot = root ? root : defaultroot
        cmd = "find #{resultspath}/#{rpmroot} -name \"#{k}*.rpm\""
        rpms = `#{cmd}`
        rpm = nil
        rpms.each { |r|
          if ! (r =~ /-debuginfo-/ || r =~ /\.src\./)
            rpm = r.strip
            break
          end
        }
        if rpm
          package k do
            source rpm
            provider Chef::Provider::Package::Rpm
            action :install
            only_if "[ -f #{rpm} ]"
          end
        end
      end
    }
    
  end

end
