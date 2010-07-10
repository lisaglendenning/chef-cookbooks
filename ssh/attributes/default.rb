
default[:components][:ssh][:root] = true  
default[:components][:ssh][:auth] = [ 'password', 'publickey' ]

default[:components][:ssh][:packages] = case node[:platform]
  when 'redhat', 'centos', 'fedora'
    ['openssh-clients', 'openssh',  'openssh-server', 'denyhosts']
  else
    ['openssh-client', 'openssh-server', 'denyhosts']
  end  
    
server = Mash.new
server[:protocol] = 'tcp'
server[:port] = 22
default[:components][:ssh][:server][:transports] = [server]
