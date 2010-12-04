
case node[:components][:webserver][:provider]
when :nginx
  include_recipe "webserver::nginx"
end


if node.components.attribute?(:firewall)
  node[:components][:webserver][:registry].each { |name,server|
    server = Mash.new(:protocol => 'tcp', :port => server[:port])
    node.set[:components][:firewall][:registry]["webserver-#{name}"] = [server]
  }
end
