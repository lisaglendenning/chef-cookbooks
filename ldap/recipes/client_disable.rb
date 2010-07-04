
#
# Resources
#

node[:components][:ldap_client][:packages].each do |p|
  package p do
    action :purge
  end
end

node[:components].delete(:ldap_client)
