
# Directory structure

diaspora = node[:components][:diaspora]

[diaspora[:root], "#{diaspora[:root]}/data"].each do |dir|
  directory dir do
    path dir
    owner diaspora[:user]
    group diaspora[:group]
    mode "0755"
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
    'htop',
    'psmisc',
    'screen',
    'java-1.6.0-openjdk',
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
    destination "#{diaspora[:root]}/sod.git"
    repository "git://github.com/MikeSofaer/sod.git"
    reference "master"
    action :sync
  end

  # TODO how to update rvm?
  execute "rvm-install" do
    cwd "#{diaspora[:root]}/sod.git"
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
  
  ['redis', 'mongodb'].each do |serv|
    template "#{serv}.conf" do
      path "/etc/#{serv}.conf"
      source "#{serv}.conf.erb"
      mode "0644"
      owner "root"
      group "root"
      variables(
        :datadir => "#{diaspora[:root]}/data"
      )
    end
    directory "#{diaspora[:root]}/data/#{serv}" do
      owner "#{serv}"
      group "#{serv}"
      mode "0755"
      recursive true
    end
  end

  service "mongod" do
    supports :restart => true, :status =>true
    action [:enable, :start]
    subscribes :restart, resources(:template => "mongodb.conf")
  end

  service "redis" do
    supports :restart => true, :status =>true
    action [:enable, :start]
    subscribes :restart, resources(:template => "redis.conf")
  end
end

# Diaspora

git "diaspora.git" do
  destination "#{diaspora[:root]}/diaspora.git"
  repository "git://github.com/diaspora/diaspora.git"
  reference "#{diaspora[:reference]}"
  action :checkout
end

execute "diaspora-install" do
  cwd "#{diaspora[:root]}/diaspora.git"
  command "source #{rvm_root}/lib/rvm && rvm use #{ruby_version} && bundle install"
  action :nothing
  subscribes :run, resources(:git => "diaspora.git"), :immediately
end

template "app_config.yml" do
  path "#{diaspora[:root]}/diaspora.git/config/app_config.yml"
  source "app_config.yml.erb"
  mode "0644"
  owner diaspora[:user]
  group diaspora[:group]
  variables(
    :config => node[:components][:diaspora][:app]
  )
end

