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
