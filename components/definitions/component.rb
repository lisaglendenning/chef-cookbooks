
define :component, :name=>nil, :attributes=>nil, :action=>:enable do
  if params[:action] == :enable
    ruby_block "enable-component-#{params[:name]}" do
      block do
        if ! node[:components][params[:name]]
          if params[:attributes]
            node[:components][params[:name]] = params[:attributes]
          else
            node[:components][params[:name]] = {}
          end
        end
      end
    end
  elsif params[:action] == :disable
    ruby_block "disable-component-#{params[:name]}" do
      block do
        if node[:components][params[:name]]
          node[:components].delete(params[:name])
        end
      end
    end
  end
end
