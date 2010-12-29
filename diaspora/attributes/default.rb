
node.default[:components][:diaspora][:domain] = "#{node[:domain]}"
node.default[:components][:diaspora][:root] = '/var/local/diaspora'
node.default[:components][:diaspora][:user] = 'nobody'
node.default[:components][:diaspora][:group] = 'nobody'

# app_config.yml
defaults = {
  'pod_url' => "http://#{node[:hostname]}.#{node[:components][:diaspora][:domain]}:80",
  'registrations_closed' => false,
  'invites_off' => false,
  'socket_debug' => false,
  'socket_host' => "0.0.0.0",
  'socket_pidfile' => "log/diaspora-wsd.pid",
  'socket_port' => 8080,
  'socket_collection_name' => "websocket",
  'socket_secure' => false,
  'socket_private_key_location' => nil,
  'socket_cert_chain_location' => nil,.
  'pubsub_server' => "https://pubsubhubbub.appspot.com/",
  'mongo_host' => "localhost",
  'mongo_port' => 27017,
  'mailer_on' => false,
  'smtp_address' => "localhost",
  'smtp_port' => 587,
  'smtp_authentication' => "none",
  'smtp_username' => nil,
  'smtp_password' => nil,
  'smtp_domain' => "#{node[:components][:diaspora][:domain]}",
  'smtp_sender_address' => "no-reply@#{node[:components][:diaspora][:domain]}"
  'google_a_site' => false,
  'piwik_id' => nil,
  'piwiki_site' => nil,
  'cloudfiles_username' => nil,
  'cloudfiles_api_key' => nil
}

node.default[:components][:diaspora][:app][:default] = Mash.new
node.default[:components][:diaspora][:app][:development] = Mash.new
node.default[:components][:diaspora][:app][:test] = Mash.new
node.default[:components][:diaspora][:app][:production] = Mash.new

defaults.each do |k,v|
  if not node[:components][:diaspora][:app][:default].has_key?(k)
    node[:components][:diaspora][:app][:default][k] = v
  end
end
