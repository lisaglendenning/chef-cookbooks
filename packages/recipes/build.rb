
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
    path "/home/#{machuser}"
  end
  
  root = node[:components][:packages][:build][:root]
  file "rpmmacros" do
    path "/root/.rpmmacros"
    owner "root"
    group "root"
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

# TODO: else
end
