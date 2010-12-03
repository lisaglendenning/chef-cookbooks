
include_recipe "accounts"

#
# Manage SSH
#

AUTHFILE = 'authorized_keys'
DOTSSH = '.ssh'

pki = data_bag_item('accounts', 'pki')

if pki.key?('users')
  pki['users'].each { |name, props|
    user_info = `getent passwd #{name}`
    if user_info.empty?
      next
    end
    
    user_info = user_info.split(':')
    dotssh = "#{user_info[5]}/#{DOTSSH}"
    directory "#{user_info[0]}-dotssh" do
      path dotssh
      owner user_info[0]
      group user_info[3]
      mode "0700"
      not_if "[ ! -d #{user_info[5]} ]"
    end 
    
    if props.key?('authorized')
      authkeys = props['authorized']
      file "#{user_info[0]}-dotssh-authkeys" do
        path "#{dotssh}/#{AUTHFILE}"
        owner user_info[0]
        group user_info[3]
        mode "0600"
        content authkeys.join("\n") + "\n"
        action :create
        not_if "[ ! -d #{dotssh} ]"
        subscribes :create, resources(:directory => "#{user_info[0]}-dotssh")
      end
      
      if props.key?('identities')
        props['identities'].each do |id, keys|
          idfile = "#{dotssh}/#{id}"
          [[idfile, keys['private']], ["#{idfile}.pub", keys['public']]].each do |pair|
            file pair[0] do
              path pair[0]
              owner user_info[0]
              group user_info[3]
              mode "0600"
              content pair[1] + "\n"
              action :create
              not_if "[ ! -d #{dotssh} ]"
              subscribes :create, resources(:directory => "#{user_info[0]}-dotssh")
            end
          end
        end
      end
    end
  }
end
