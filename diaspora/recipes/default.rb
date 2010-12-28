
# Requirements

case node[:platform]
when 'redhat', 'centos', 'fedora'
  packages = [
    'cpio',
    'libxml2-devel', 
    'libxslt-devel',
    'gcc-c++',
    'openssl-devel',
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
end

# Ruby 1.87

case node[:platform]
when 'redhat', 'centos', 'fedora'
  packages = [
    'git'
  ]
  
  packages.each do |p|
    package p do
      action :upgrade
    end
  end
  
  # RVM
  
  remote_file "rvm-install-head" do
    path "/tmp/rvm-install-head"
    source "http://rvm.beginrescueend.com/releases/rvm-install-head"
    mode "0755"
    backup false
  end
  
  execute "rvm-install-head" do
    command "/tmp/rvm-install-head"
    action :nothing
    subscribes :run, resources(:remote_file => "rvm-install-head")
  end
end
