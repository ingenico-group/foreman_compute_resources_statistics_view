if SETTINGS[:compute_resource_statistics_view]
  SETTINGS[:compute_resource_statistics_view].reject { |k,v| v[:view] && v[:view] != :edit_statistic_values }.keys.sort.map do |k|
    after = SETTINGS[:compute_resource_statistics_view][k.to_sym][:after]
    Deface::Override.new(
      :virtual_path => "compute_resources/_form",
      :name => "statistics_#{k}",
      :insert_after => "div##{after}",
      :text => "\n   <%= edit_compute_resource_statistics_form @compute_resource %>"
    )
  end
end