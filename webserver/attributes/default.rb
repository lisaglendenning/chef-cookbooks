
node.default[:components][:webserver][:registry] = Mash.new
node.default[:components][:webserver][:provider] = :nginx
node.default[:components][:webserver][:user] = :nobody
node.default[:components][:webserver][:group] = :nobody
