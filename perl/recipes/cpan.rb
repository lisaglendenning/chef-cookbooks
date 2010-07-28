
include_recipe "packages"

modules = { }
node[:components][:perl][:registry].each { |p,v|
  if v == :install
    # already installed?
    outs = `perldoc -l #{p}`
    if $? != 0:
      modules[p] = v
    end
  end
}

if modules.len? > 0
  script = "/tmp/cpan.py"
  cookbook_file "cpan.py" do
    path script
    source "cpan.py"
    owner "root"
    group "root"
    mode 0755
  end
  
  cmd = "#{script}"
  modules.each { |k,v|
    cmd << " \"#{v} #{k}\""
  }
  
  execute "run-cpan" do
    command cmd
  end
end
