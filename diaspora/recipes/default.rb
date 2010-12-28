
# Root

root = node[:components][:diaspora][:root]

directory root do
  path root
  owner node[:components][:diaspora][:user]
  group node[:components][:diaspora][:group]
  mode "0755"
  recursive true
end


case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  # Bootstrap
  
  packages = [
    'cpio',
    'libxml2-devel', 
    'libxslt-devel',
#    'gcc-c++',
#    'openssl-devel',
    'htop',
    'psmisc',
    'screen',
    'java',
    'bzip2'
  ]
  
  packages.each do |p|
    package p do
      action :upgrade
    end
  end
    
  # Build tools
  
  packages = [
    'gcc',
    'automake',
    'autoconf',
    'libtool',
    'make',
    'git'
  ]
  
  packages.each do |p|
    package p do
      action :upgrade
    end
  end
  
  # RVM
  
  git "sod.git" do
    destination "#{root}/sod.git"
    repository "git://github.com/MikeSofaer/sod.git"
    reference "master"
    action :sync
  end

  execute "rvm-install" do
    cwd "#{root}/sod.git"
    command "bash rvm_install.sh"
    action :nothing
    subscribes :run, resources(:git => "sod.git"), :immediately
  end  
  
  # Ruby deps
  
  packages = [
    'gcc-c++',
    'patch', 
    'readline', 
    'readline-devel', 
    'zlib', 
    'zlib-devel', 
    'libyaml-devel', 
    'libffi-devel',
    'openssl-devel'
  ]  

  packages.each do |p|
    package p do
      action :upgrade
    end
  end

  # Diaspora

  git "#{root}/diaspora.git" do
    repository "git://github.com/diaspora/diaspora.git"
    reference "master"
    action :sync
  end
  
end
