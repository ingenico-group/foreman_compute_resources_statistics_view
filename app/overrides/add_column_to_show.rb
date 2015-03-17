if SETTINGS[:compute_resource_statistics_view]
  SETTINGS[:compute_resource_statistics_view].reject { |k,v| v[:view] && v[:view] != :compute_resources_properties }.keys.sort.map do |k|
    after = SETTINGS[:compute_resource_statistics_view][k.to_sym][:after]
    Deface::Override.new(
      :virtual_path => "compute_resources/show",
      :name => "title_#{k}",
      :insert_after => "tr:contains('#{after}')",
      :text => "\n   <tr> <td><%= compute_resource_statistics_title '#{k}' %></td><td><%= compute_resource_statistics_content @compute_resource, '#{k}' %></td></tr>"
    )
  end
end