
case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  # EPEL
  packages = [ 'mongodb', 'mongodb-server']
  packages.each do |p|
    package p do
      action :upgrade
    end
  end

end
