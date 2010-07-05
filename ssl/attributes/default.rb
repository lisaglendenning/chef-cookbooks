
rhels = ['redhat', 'centos', 'fedora']

default[:components][:ssl][:packages] = ['openssl']

default[:components][:ssl][:pkidir] = case node[:platform]
    when 'redhat', 'centos', 'fedora'
      '/etc/pki/tls'
    else
      '/etc/ssl'
    end

default[:components][:ssl][:certregistry] = Mash.new
