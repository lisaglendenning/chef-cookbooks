
include_recipe "packages"

#
# Hudson user
#

hudsonuser = node[:components][:hudson][:user]
hudsongroup = node[:components][:hudson][:group]
hudsonhome = node[:components][:hudson][:home]
  
user hudsonuser do
  comment "hudson user"
  home "/home/#{hudsonuser}"
  shell "/bin/bash"
  system true
end
group hudsongroup do
  members [hudsonuser]
  append true
end

#
# Hudson service
#

service 'hudson' do
  supports :restart => true, :status => true
  action [:enable, :start]
  only_if "[ -x /etc/rc.d/init.d/hudson ] && [ -d #{hudsonhome} ]"
end


#
# Hudson control files
#

directory hudsonhome do
  path hudsonhome
  owner hudsonuser
  group hudsongroup
  mode 0755
end

#
# SSL
#

if node[:components][:hudson][:ssl]
  
  include_recipe "ssl"

  keystore = "#{hudsonhome}/keystore.jks"
  keypass = 'hudson' # password is required by default java keystore

  # Create keypair and keystore
  
  server = node[:fqdn]
  dname = node[:components][:hudson][:ssl][:dname] # must be set!
  execute "create-hudson-keystore" do
    command "keytool -genkey -keyalg RSA -keysize 1024 -alias #{server} -dname \"#{dname}\" -keypass #{keypass} -storepass #{keypass} -storetype jks -keystore #{keystore}"
    path ["#{node[:components][:hudson][:java]}/bin"]
    creates keystore
    cwd hudsonhome
    user hudsonuser
    group hudsongroup
    umask 027
  end

  # TODO: Import CA
  
  cakey = node[:components][:hudson][:ssl][:ca][:key]
  cafile = nil
  execute "import-hudson-ca" do
    command = "keytool -import -noprompt -trustcacerts -alias #{cakey} -file #{cafile} -storepass #{keypass} -storetype jks -keystore #{keystore}"
    path = ["#{node[:components][:hudson][:java]}/bin"]
    action :nothing
    cwd hudsonhome
    user hudsonuser
    group hudsongroup
    umask 027
  end
  
  # Generate CSR
  
  csrfile = "#{server}.csr"
  execute "create-hudson-csr" do
    command "keytool -certreq -alias #{server} -file #{csrfile} -keypass #{keypass} -storepass #{keypass} -keystore #{keystore}"
    path ["#{node[:components][:hudson][:java]}/bin"]
    action :nothing
    cwd hudsonhome
    user hudsonuser
    group hudsongroup
    umask 022
    subscribes :run, resources(:execute => "create-hudson-keystore"), :immediately
  end
  
  # TODO: get CSR signed
  # example: openssl x509 -req -days 1825 -in example.com.csr -out example.com.crt -CA ca.crt -CAkey ca.key -CAserial serial -extensions server -extfile openssl.cnf
  
  crtfile = "#{server}.crt"
  
  # Import signed certificate
  # NOTE:  The data to be imported must be either in binary or base64 encoding format (between -----BEGIN/------END)
  # can be converted using: openssl x509 -in cert.crt.pem -inform PEM -out cert.crt.der -outform DER
  execute "import-hudson-crt" do
    command = "keytool -import -noprompt -trustcacerts -alias #{server} -file #{crtfile} -storepass #{keypass} -storetype jks -keystore #{keystore}"
    path = ["#{node[:components][:hudson][:java]}/bin"]
    action :nothing
    cwd hudsonhome
    user hudsonuser
    group hudsongroup
    umask 027
  end  
  
  # Modify command-line options if necessary
  opts = node[:components][:hudson][:opts]
  [['httpsPort', node[:components][:hudson][:port]],
   ['httpPort', -1],
   ['httpsKeyStore', keystore],
   ['httpsKeyStorePassword', keypass]].each do |kv|
     opt = "--#{kv[0]}=#{kv[1]}"
      if !opts.include?(opt)
        opts.length.times { |i|
          if opts[i]["--#{kv[0]}="]
            opts[i] = opt
            break
          end
        }
      end
      if !opts.include?(opt)
        opts << opt
      end
  end
  
end

cookbook_file "hudson-server" do
  path "#{hudsonhome}/hudson-server"
  owner hudsonuser
  group hudsonuser
  mode 0755
  source "hudson-server"
  notifies :restart, resources(:service => 'hudson')
end

template "hudson-service" do
  source "hudson.erb"
  path "/etc/rc.d/init.d/hudson"
  owner "root"
  group "root"
  mode 0755
  variables(:hudson => node[:components][:hudson])
  notifies :restart, resources(:service => 'hudson')
end


#
# Hudson source
#

hudsonfile = node[:components][:hudson][:download][/[^\/]+$/]

remote_file hudsonfile do
  source node[:components][:hudson][:download]
  path "#{hudsonhome}/#{hudsonfile}"
  owner hudsonuser
  group hudsongroup
  mode 0755
  notifies :restart, resources(:service => 'hudson')
end
