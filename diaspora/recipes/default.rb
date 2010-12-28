
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
  
  rvm_root = '/usr/local/rvm'
  
  ruby_version = "ree-1.8.7-2010.02"
  
  # RVM packages ?
  rvms = ['zlib', 'openssl', 'readline']
  rvms.each do |r|
    execute "rvm-install-#{r}" do
      command "rvm package install #{r}"
    end
  end
  
  # And, Ruby
  execute "ruby-install" do
    command "rvm install #{ruby_version} -C --with-zlib-dir=#{rvm_root}/usr --with-readline-dir=#{rvm_root}/usr --with-openssl-dir=#{rvm_root}/usr"
  end
end

case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  include_recipe "diaspora::mongodb"

  # Diaspora

  git "#{root}/diaspora.git" do
    repository "git://github.com/diaspora/diaspora.git"
    reference "master"
    action :sync
  end
  
end
