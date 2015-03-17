if SETTINGS[:compute_resource_statistics_view]
  SETTINGS[:compute_resource_statistics_view].reject { |k,v| v[:view] && v[:view] != :compute_resources_list }.keys.sort.map do |k|
    after = SETTINGS[:compute_resource_statistics_view][k.to_sym][:content_after]
    Deface::Override.new(
      :virtual_path => "compute_resources/index",
      :name => "content_#{k}",
      :insert_after => "td:contains('#{after}')",
      :text => "\n    <td class=\"hidden-tablet hidden-phone\"><%= compute_resource_statistics_content compute, '#{k}' %></td>"
    )
  end
end
