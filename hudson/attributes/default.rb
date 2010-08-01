
node.default[:components][:hudson][:download] = "http://hudson-ci.org/latest/hudson.war"
node.default[:components][:hudson][:home] = "/opt/hudson"
node.default[:components][:hudson][:user] = 'hudson'
node.default[:components][:hudson][:group] = 'hudson'
node.default[:components][:hudson][:port] = 8080
node.default[:components][:hudson][:opts] = ["--httpPort=#{node[:components][:hudson][:port]}"]

# Default to OpenJDK
node.default[:components][:hudson][:java] = '/usr/lib/jvm/jre-1.6.0-openjdk'
node.default[:components][:packages][:registry]['java-1.6.0-openjdk'][:action] = :install

# Register with firewall
if node.components.attribute?(:firewall)
  node.set[:components][:firewall][:registry][:hudson] = 
    [{:protocol => 'tcp', :port => node[:components][:hudson][:port]}]
end
