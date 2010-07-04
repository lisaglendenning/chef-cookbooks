
# TODO manage install / uninstall of recipes

components = { }

# get my recipes (better way to do this ?)
search(:node, "name:#{node.name}") do |n|
  run_list = []
  run_list.concat(n['run_list'])
  while ! run_list.empty?
    item = run_list.delete_at(0)
    if item =~ /role[/
      role = item.trim()
      role.sub!('role[', '')
      role.sub!(']')
      search(:role, role) do |r|
        run_list.concat(r['run_list'])
      end
    elsif item =~ /recipe[/
      recipe = item.trim()
      recipe.sub!('recipe[', '')
      recipe.sub!(']')
      recipe.sub!('::', '_')
      components[recipe] = { }
    else
      recipe = item.trim()
      recipe.sub!('::', '_')
      components[recipe] = { }
    end
  end
end

