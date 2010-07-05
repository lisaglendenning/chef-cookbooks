
rhels = ['redhat', 'centos', 'fedora']

default[:components][:ssh][:packages] = case node[:platform]
  when rhels
    ['openssh-clients', 'openssh']
  else
    ['openssh-client', 'openssh-server']
  end

default[:components][:ssh][:root] = true  
default[:components][:ssh][:auth] = [ :password, :publickey ]
  
server = Mash.new
server[:protocol] = :tcp
server[:port] = 22
default[:components][:ssh][:server][:transports] = [server]
