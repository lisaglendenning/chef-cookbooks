
plugindir = '/etc/yum/pluginconf.d'

define :yum_plugin, :action => :enable, :plugin => nil do
  filename = "#{plugindir}/#{params[:plugin]}.conf"
  if params[:action] == :enable
    ruby_block "yum_plugin-#{params[:plugin]}-enable" do
      block do
        f = File.new(filename, "r")
        lines = f.readlines
        f.close
        changed = false
        section = nil
        lines.each_with_index do |l,i|
          content = l.strip
          comment = content.index('#')
          if comment
            content = content[0...comment]
          end
          if ! content.empty?
            if content =~ /^\[(.+)\]/
              section = $1.strip
            elsif content =~ /^(.+?)\s*=\s*(.+)/
              k = $1.strip 
              v = $2.strip
              if section == 'main' && k == 'enabled':
                if v != '1'
                  changed = true
                  v = '1'
                  lines[i] = "%s=%s\n" % [k,v]
                end
              end
            else
              raise RuntimeError, l
            end
          end
        end
        if changed
          f = File.new(filename, "w")
          lines.each do |l|
            f.puts(l)
          end
          f.close
        end
      end
      action :create
      only_if "[ -f #{filename} ]"
    end
    
  # TODO: elsif params[:action] == :disable

end
