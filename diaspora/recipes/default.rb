
# requirements

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
