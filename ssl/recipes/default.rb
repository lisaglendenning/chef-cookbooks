
#
# Resources
#

packages = ['openssl']

packages.each { |p|
  package p do
   action :upgrade
  end
}

node[:components][:ssl][:certregistry].each { |k,v|
  x509cert k do
    action :enable
    certname k
    cert v[:content]
  end
}
