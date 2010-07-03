
define :component, :key=>nil, :attributes=>nil, :action=>:enable do
  if params[:action] == :enable
    ruby_block "enable-component-#{params[:key]}" do
      block do
        if ! node[:components][params[:key]]
          if params[:attributes]
            node[:components][params[:key]] = params[:attributes]
          else
            node[:components][params[:key]] = {}
          end
        end
      end
    end
  elsif params[:action] == :disable
    ruby_block "disable-component-#{params[:key]}" do
      block do
        if node[:components][params[:key]]
          node[:components].delete(params[:key])
        end
      end
    end
  end
end
