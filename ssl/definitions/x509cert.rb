
rhels = ['redhat', 'centos', 'fedora']
  
define :x509cert, :action => :enable, :certname => nil, :cert => nil do
  certdir = node[:components][:ssl][:pkidir] + '/certs'
  filename = '#{certdir}/#{params[:certname]}.crt'
  if params[:action] == :enable
    file "x509cert-#{params[:certname]}" do
      path filename
      mode "0644"
      owner "root"
      group "root"
      action :create
      content params[:cert]
      notifies :create, resources(:rubyblock => "x509cert-#{params[:certname]}-enable")
      not_if "[ -f #{filename} ]"
    end
    rubyblock "x509cert-#{params[:certname]}-enable" do
      block do
        hash = `openssl x509 -noout -hash -in #{filename}`
        hashlink = "#{certdir}/#{hash}.0"
        if not File.exist?(hashlink)
          File.symlink(filename, hashlink)
        end
      end
      action :nothing
    end
  elsif params[:action] == :disable
    rubyblock "x509cert-#{params[:certname]}-disable" do
      block do
        hash = `openssl x509 -noout -hash -in #{filename}`
        File.unlink("#{certdir}/#{hash}.0")
      end
      action :create
      notifies :delete, resources(:file => "x509cert-#{params[:certname]}")
    end
    file "x509cert-#{params[:certname]}" do
      path filename
      action :nothing
    end
  end

end
