case node[:platform]
when 'redhat', 'centos', 'fedora'
  node[:components][:packages][:repos][:official].each { |k,v|
    template k do
      path node[:components][:packages][:repodir] + "/#{k}.repo"
      source "repo.erb"
      mode 0644
      owner "root"
      group "root"
      variables(
        :repo => v
      )
    end
  }
  
  repofiles = []
  Dir.entries(node[:components][:packages][:repodir]).each { |f|
    if f[-5..-1] == '.repo'
      repofiles << f
    end
  }
  
  repofiles.each { |f|
    reponame = f[0..-6]
    if ! node[:components][:packages][:repos][:official].key?(reponame)
      if ! node[:components][:packages][:repos][:extra].key?(reponame)
        node[:components][:packages][:repos][:extra][reponame] = Mash.new
      end
    end
  }
  
else
  template 'sources.list' do
    path node[:components][:packages][:repodir] + "/sources.list"
    source "sources.list.erb"
    mode 0644
    owner "root"
    group "root"
    variables(
      :repos => node[:components][:packages][:repos][:official]
    )
  end
end
