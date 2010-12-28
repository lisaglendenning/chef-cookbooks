
case node[:platform]
when 'redhat', 'centos', 'fedora'
  
  # EPEL
  packages = [  ]
  packages.each do |p|
    package p do
      action :upgrade
    end
  end

end
