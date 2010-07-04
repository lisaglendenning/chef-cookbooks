
props = node[:components][:ssl]

#
# Resources
#

props[:packages].each { |p|
  package p do
   action :upgrade
  end
}
