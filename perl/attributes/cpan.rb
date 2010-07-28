
# we use pexpect for cpan automation
packages = ['perl', 'python', 'pexpect']
packages.each { |p|
  node.set[:components][:packages][:registry][p] = :install
}
