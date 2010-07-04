
#
# Resources
#

node[:components][:ssl][:packages].each { |p|
  package p do
   action :upgrade
  end
}
