
# Delete validation key if we have a client key

execute "remove-validation" do
  command "if [ -f /etc/chef/validation.pem ]; then rm -f /etc/chef/validation.pem; fi"
  only_if "[ -f /etc/chef/client.pem ]"
  action :run
end
