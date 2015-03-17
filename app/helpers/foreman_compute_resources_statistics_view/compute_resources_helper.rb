module ForemanComputeResourcesStatisticsView
  module ComputeResourcesHelper

    def compute_resource_statistics_title(column)
      title = SETTINGS[:compute_resource_statistics_view][column.to_sym][:title]
      return title
    end 

    def compute_resource_statistics_content(compute_resource, column)
      content = SETTINGS[:compute_resource_statistics_view][column.to_sym][:content]
      if content =~ /(.*)\[(.*)\]/
        return compute_resource.send($1)[$2.gsub(/['"]/,'')]
      else
        return compute_resource.send(content)
      end
    end 

    def edit_compute_resource_statistics_form(compute_resource)
      compute_resource_types_for_statistics = ComputeResource::COMPUTE_RESOURCE_TYPES_TO_HAVE_STATISTICS.map{|ctype| ctype.split("::").last.downcase}
      statistics_form = ""
      if compute_resource.new_record? or compute_resource.can_have_statistics?
        statistics_form = "<legend>Statistics fields</legend>" 
        statistic_fields = [["max_cpus_limit", "Max CPUs"], ["max_memory_limit", "Max Memory(GBs)"], ["max_size_limit", "Max Size(GBs)"], ["cpus_overusage", "CPUs Overusage(%)"], ["memory_overusage", "Memory Overusage(%)"], ["size_overusage", "Size Overusage(%)"]]
        for statistic_field in statistic_fields          
          statistics_form += "<div class='clearfix'><div class='form-group #{!compute_resource.errors[statistic_field[0].to_sym].empty? ? 'has-error' : ''}'><label for='#{statistic_field[0]}' class='col-md-2 control-label'>#{statistic_field[1]}</label>
          <div class='col-md-4'><input type='text' value='#{compute_resource.send(statistic_field[0])}' size='30' name='compute_resource[#{statistic_field[0]}]' id='compute_resource_#{statistic_field[0]}' class='form-control '>
          <span class='help-block'>Numeric values only. Ex. 50 or 50.5 </span></div><span class='help-block help-inline'>#{compute_resource.errors[statistic_field[0].to_sym].to_sentence}</span></div></div>"
        end 
        statistics_form += "<div class='clearfix'><div class='form-group #{!compute_resource.errors[ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym].empty? ? 'has-error' : ''}'><label for='#{ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]}' class='col-md-2 control-label'>Fail host creation when CPU, RAM or Disk are not sufficient</label>
          <div class='col-md-4'>
          <input type='hidden' value='0' name='compute_resource[#{ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]}]' id='compute_resource_#{ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]}'>
          <input type='checkbox' value='1' name='compute_resource[#{ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]}]' id='compute_resource_#{ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]}' #{compute_resource.send(ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym) ? 'checked=true' : ''}>
          </div><span class='help-block help-inline'>#{compute_resource.errors[ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym].to_sentence}</span></div></div>"
        statistics_form = "<div id='statistics_fields' style='#{(compute_resource.new_record? or !compute_resource.can_have_statistics?) ? 'display:none;' : ''}'>#{statistics_form}</div>"+"<script>$('#compute_resource_provider').change(function () {   if(jQuery.inArray( $(this).val().toLowerCase(), #{compute_resource_types_for_statistics}) >= 0){ $('#statistics_fields').show() }else{ $('#statistics_fields').hide() }   });</script>"
      end 
      statistics_form.html_safe
    end

  end
end
