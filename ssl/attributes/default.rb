
rhels = ['redhat', 'centos', 'fedora']

default[:components][:ssl][:packages] = ['openssl']

default[:components][:ssl][:pkidir] = case node[:platform]
    when rhels
      '/etc/pki/tls'
    else
      '/etc/ssl'
    end
