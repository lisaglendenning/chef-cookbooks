
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
        k = nil
        v = nil
        lines.each_with_index { |l,i|
          content = l.strip
          comment = content.index('#')
          if ! comment.nil?
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
            else # must be a value continuation
              v << line
            end
          end
        }
        if changed
          f = File.new(filename, "w")
          lines.each { |l|
            f.puts(l)
          }
          f.close
        end
      end
      action :create
      only_if "[ -f #{filename} ]"
    end
  # TODO: elsif params[:action] == :disable
  end
end
