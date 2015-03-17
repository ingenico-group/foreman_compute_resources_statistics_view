if SETTINGS[:compute_resource_statistics_view]
  SETTINGS[:compute_resource_statistics_view].reject { |k,v| v[:view] && v[:view] != :compute_resources_list }.keys.sort.map do |k|
    after = SETTINGS[:compute_resource_statistics_view][k.to_sym][:title_after]
    Deface::Override.new(
      :virtual_path => "compute_resources/index",
      :name => "title_#{k}",
      :insert_after => "th:contains('#{after}')",
      :text => "\n    <th class=\"hidden-tablet hidden-phone\"><%= compute_resource_statistics_title '#{k}' %></th>"
    )
  end
end
