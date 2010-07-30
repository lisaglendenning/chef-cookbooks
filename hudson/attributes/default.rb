
node.default[:components][:hudson][:download] = "http://hudson-ci.org/latest/hudson.war"
node.default[:components][:hudson][:home] = "/opt/hudson"
node.default[:components][:hudson][:user] = 'hudson'
node.default[:components][:hudson][:group] = 'hudson'

# Default to OpenJDK
node.default[:components][:hudson][:java] = '/usr/lib/jvm/jre-1.6.0-openjdk'
node.default[:components][:packages][:registry]['java-1.6.0-openjdk'][:action] = :install