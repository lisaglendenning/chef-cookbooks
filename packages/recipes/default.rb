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
  repodir = node[:components][:packages][:repodir]
  Dir.entries(repodir).each { |f|
    if f[-5..-1] == '.repo'
      repofiles << f
    end
  }
  
  repofiles.each { |fname|
    reponame = fname[0..-6]
    if ! node[:components][:packages][:repos][:official].key?(reponame)
      if ! node[:components][:packages][:repos][:extra].key?(reponame)
        repo = Mash.new
        node[:components][:packages][:repos][:extra][reponame] = repo

        f = File.new("#{repodir}/#{fname}", "r")
        section = nil    
        f.each_line do |line|
          line = line.strip
          comment = line.index('#')
          if comment
            line = line[0...comment]
          end
          if line.empty?
            continue
          end
          if line =~ /^\[(.+)\]/
            section = Mash.new
            repo[$1.strip] = section
          elsif line =~ /^(.+?)\s*=\s*(.+)/
            section[$1.strip] = $2.strip
          else
            # FIXME: error
          end          
        f.close
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
