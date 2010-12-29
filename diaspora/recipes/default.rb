
# Root

root = node[:components][:diaspora][:root]

directory root do
  path root
  owner node[:components][:diaspora][:user]
  group node[:components][:diaspora][:group]
  mode "0755"
  recursive true
end

# Ruby environment

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

  rvm_root = '/usr/local'
  
  git "sod.git" do
    destination "#{root}/sod.git"
    repository "git://github.com/MikeSofaer/sod.git"
    reference "master"
    action :sync
  end

  # TODO will this rerun if sod.git is updated and rvm_root exists?
  # TODO how to update rvm?
  execute "rvm-install" do
    cwd "#{root}/sod.git"
    command "bash rvm_install.sh"
    action :run
    creates "#{rvm_root}/lib/rvm"
  end  
  
  # Ruby deps

  ruby_version = "ree-1.8.7-2010.02"
  
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
  
  # Ruby EE dependencies
  rvms = ['ree_dependencies']
  rvms.each do |r|
    execute "rvm-install-#{r}" do
      command "source #{rvm_root}/lib/rvm && rvm package install #{r}"
      action :nothing
      subscribes :run, resources(:execute => "rvm-install"), :immediately
    end
  end
  
  # And, Ruby
  execute "ruby-install" do
    command "source #{rvm_root}/lib/rvm && rvm install #{ruby_version} -C --with-zlib-dir=#{rvm_root}/rvm/usr --with-readline-dir=#{rvm_root}/rvm/usr --with-openssl-dir=#{rvm_root}/rvm/usr"
    creates "#{rvm_root}/rvm/rubies/#{ruby_version}"
  end
  
  # Bundler
  execute "bundler-install" do
    command "source #{rvm_root}/lib/rvm && rvm use #{ruby_version} && gem install bundler"
    #action :nothing
    subscribes :run, resources(:execute => "ruby-install"), :immediately
  end
  
end

# Application dependencies

case node[:platform]
when 'redhat', 'centos', 'fedora'

  packages = [
    'ImageMagick', 
    'redis', 
    'mongodb', 
    'mongodb-server'
  ]
  
  packages.each do |p|
    package p do
      action :upgrade
    end
  end
end

# And, Diaspora

git "#{root}/diaspora.git" do
  repository "git://github.com/diaspora/diaspora.git"
  reference "master"
  action :sync
end

