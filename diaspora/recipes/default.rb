
# Directory structure

diaspora = node[:components][:diaspora]

[diaspora[:root], "#{diaspora[:root]}/run", "#{diaspora[:root]}/source", "#{diaspora[:root]}/data"].each do |dir|
  directory dir do
    path dir
    owner diaspora[:user]
    group diaspora[:group]
    mode "0777"
    recursive true
  end
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
    destination "#{diaspora[:root]}/source/sod.git"
    repository "git://github.com/MikeSofaer/sod.git"
    reference "master"
    action :sync
  end

  # TODO how to update rvm?
  execute "rvm-install" do
    cwd "#{diaspora[:root]}/source/sod.git"
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
  
  ['redis', 'mongodb'].each do |conf|
    template "#{conf}.conf" do
      path "/etc/#{conf}.conf"
      source "#{conf}.conf.erb"
      mode "0644"
      owner diaspora[:user]
      group diaspora[:group]
      variables(
        :rundir => "#{diaspora[:root]}/run",
        :datadir => "#{diaspora[:root]}/data"
      )
    end
  end

  service "mongod" do
    supports :restart => true, :status =>true
    action [:enable, :start]
    subscribes :restart, resources(:template => "mongodb.conf")
  end
end

# Diaspora

git "diaspora.git" do
  destination "#{diaspora[:root]}/source/diaspora.git"
  repository "git://github.com/diaspora/diaspora.git"
  reference "master"
  action :sync
end

execute "diaspora-install" do
  cwd "#{diaspora[:root]}/source/diaspora.git"
  command "source #{rvm_root}/lib/rvm && rvm use #{ruby_version} && bundle install"
  action :nothing
  subscribes :run, resources(:git => "diaspora.git"), :immediately
end

