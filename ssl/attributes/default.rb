
node.default[:components][:ssl][:pkidir] = case node[:platform]
    when 'redhat', 'centos', 'fedora'
      '/etc/pki/tls'
    else
      '/etc/ssl'
    end
