
#
# Resources
#

node[:components][:ssl][:packages].each { |p|
  package p do
   action :upgrade
  end
}

node[:components][:ssl][:caregistry].each { |k,v|
  x509ca k do
    action :enable
    certname k
    cert v
  end
}
