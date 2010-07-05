
# Delete validation key if we have a client key

# TODO: parse from config file ?
VALIDATION_KEY = '/etc/chef/validation.pem'
CLIENT_KEY = '/etc/chef/client.pem'

execute "remove-validation" do
  command "if [ -f #{VALIDATION_KEY} ]; then rm -f #{VALIDATION_KEY}; fi"
  only_if "[ -f {CLIENT_KEY} ]"
  action :run
end
