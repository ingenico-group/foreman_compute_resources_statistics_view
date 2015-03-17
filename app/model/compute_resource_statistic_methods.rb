module ComputeResourceStatisticMethods

	extend ActiveSupport::Concern
	COMPUTE_RESOURCE_TYPES_TO_HAVE_STATISTICS = ["Foreman::Model::Ovirt", "Foreman::Model::Libvirt", "Foreman::Model::Vmware"]
	COMPUTE_RESOURCE_STATISTICS_COLUMNS = [["max_cpus_limit", "integer"], ["max_memory_limit", "float"], ["max_size_limit", "float"], ["cpus_overusage", "integer"], ["memory_overusage", "float"], ["size_overusage", "float"]]
	COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN = ["validate_capacity_on_host_creation", "boolean"]
	included do
		has_one :compute_resource_statistic, :dependent => :destroy
		#validates :max_cpus_limit, :max_memory_limit, :max_size_limit, :cpus_overusage, :memory_overusage, :size_overusage, :numericality => true, :allow_nil => true, :allow_blank => true
		#validates ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS.map{|statistic_column| statistic_column[0].to_sym }, :numericality => true, :allow_nil => true, :allow_blank => true
		validate :validate_statistics_max_fields
	end

	def validate_statistics_max_fields
		for max_field in ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS
			if self.send(max_field[0]).present? and (!["Float", "Fixnum"].include?(self.send(max_field[0]).class.to_s))
				errors.add(max_field[0].to_sym, "is not numeric")
			end
		end
	end

	def can_have_statistics?
		ComputeResource::COMPUTE_RESOURCE_TYPES_TO_HAVE_STATISTICS.include?(self.type)
	end

	def max_limit_in_byte(max_type)
		self.respond_to? max_type ? self.send(max_type).to_f * (1024 * 1024 * 1024) : 0
	end

	def statistic_value_in_gb(val)
		(val/(1024 * 1024 * 1024).to_f).round(2)
	end
	
	def usage_statistics_html_box(statistic_type, max_value, used_value, tooltip_text, percent_filed, color)
		color_box_style = if percent_filed.to_i >= 100
			"width: 100%;-webkit-border-radius: 6px;-moz-border-radius: 6px;border-radius: 6px;"
		else
			"width: #{percent_filed}%;-webkit-border-top-left-radius: 6px;-webkit-border-bottom-left-radius: 6px;
			-moz-border-radius-topleft: 6px;-moz-border-radius-bottomleft: 6px;
			border-top-left-radius: 6px;border-bottom-left-radius: 6px;"
		end
		"<div onmouseover='$(this).tooltip(\"show\");' onmouseout='$(this).tooltip(\"hide\");' data-placement='top' data-toggle='tooltip' data-original-title='#{tooltip_text}'
		style='width: 30%;border: 1px solid #DDDDDD;margin-right: 5px;float:left;
		-webkit-border-radius: 7px;
		-moz-border-radius: 7px;
		border-radius: 7px;'>
		<div style='position: relative;z-index: 2;text-align:center;height: 20px;font-size: 10px; padding-top: 5px;'>#{((!max_value.to_s.blank? or !used_value.to_s.blank?) ? "#{used_value}/#{max_value}" : "")} #{statistic_type}</div>
		<div style='position: relative;background-color: #{color};z-index: 1;margin-top: -20px;#{color_box_style}'>&nbsp;</div>
		</div>"
	end

	def calculate_statistics(statistic_type)
		display_used_value = used_value = compute_resource_statistic.send("used_"+statistic_type).to_f.round(2)
		display_max_value = max_value = self.send("max_"+statistic_type+"_limit").to_f.round(2)
		overusage = self.send(statistic_type+"_overusage").to_f.round(2)
		display_used_value = used_value = (used_value == used_value.to_i ? used_value.to_i : used_value)
		display_max_value = max_value = (max_value == max_value.to_i ? max_value.to_i : max_value)
		if ["memory", "size"].include?(statistic_type)
			display_max_value = "#{max_value} GB"
			display_used_value = "#{used_value} GB"
		end
		statistics_view = ""
		if (max_value > 0 and used_value > 0)
			if used_value <= max_value
				percent_filed = (used_value.to_f/max_value.to_f) * 100
				statistics_view = usage_statistics_html_box(statistic_type.upcase, display_max_value, display_used_value, "Used #{display_used_value} of #{display_max_value} #{statistic_type} on #{compute_resource_statistic.updated_at.strftime("%b %d, %Y %H:%M")}", percent_filed.round(2), "#47A447")
			elsif overusage_value = ((max_value/100.to_f)*overusage) and  used_value <= overusage_value
				percent_filed = (used_value/((max_value/100.to_f)*overusage).to_f) * 100
				statistics_view = usage_statistics_html_box(statistic_type.upcase, display_max_value, display_used_value, "Used #{display_used_value} of #{display_max_value} #{statistic_type} on #{compute_resource_statistic.updated_at.strftime("%b %d, %Y %H:%M")}", percent_filed.round(2), "#F0DB4D")
			else
				percent_filed = (used_value/((max_value/100.to_f)*(overusage + 50)).to_f) * 100
				statistics_view = usage_statistics_html_box(statistic_type.upcase, display_max_value, display_used_value, "Used #{display_used_value} of #{display_max_value} #{statistic_type} on #{compute_resource_statistic.updated_at.strftime("%b %d, %Y %H:%M")}", percent_filed.round(2), "#FC5A5A")
			end
		else
			statistics_view = usage_statistics_html_box("No #{statistic_type} values", "", "", "No values recorded", 0, "white")
		end
		statistics_view
	end

	def usage_statistics
		statistics_html = if compute_resource_statistic
			calculate_statistics("cpus") + calculate_statistics("memory") + calculate_statistics("size")
		else
			"No Statistics"
		end
		"<div style='width:100%;'>#{statistics_html}</div>".html_safe
	end

	def ovirt_statistics
		used_cpus = 0
		used_memory = 0 
		used_size = 0
		for vm in vms.all
			if vm.ready?
				used_cpus += vm.cores.to_i
				used_memory += vm.memory.to_i  
			end         
		end
		for storage_domain in self.storage_domains
			used_size += storage_domain.used.to_i
		end     
		return {:used_cpus => used_cpus, :used_memory => statistic_value_in_gb(used_memory), :used_size => statistic_value_in_gb(used_size)}
	end

	def libvirt_statistics
		used_cpus = 0
		used_memory = 0
		used_size = 0
		for vm in vms.all
			if vm.ready?
				used_cpus += vm.cpus.to_i
				used_memory += (vm.memory_size*1024)
			end
		end
		for storage_pool in self.storage_pools
			used_size += storage_pool.allocation.to_i
		end     
		return {:used_cpus => used_cpus, :used_memory => statistic_value_in_gb(used_memory), :used_size => statistic_value_in_gb(used_size)}
	end

	def vmware_statistics
		used_cpus = 0
		used_memory = 0
		used_size = 0
		for vm in vms.all
			if vm.ready?
				used_cpus += vm.cpus.to_i
				used_memory += vm.memory.to_i
			end
		end
		for ds in datastores
			used_size += (ds.capacity.to_i - ds.freespace.to_i)
		end 
		{:used_cpus => used_cpus, :used_memory => statistic_value_in_gb(used_memory), :used_size => statistic_value_in_gb(used_size)}
	end

	def ovirt_max_values   
		max_size = 0    
		for storage_domain in self.storage_domains
			max_size += storage_domain.available.to_i + storage_domain.used.to_i        
		end
		return {:max_cpus_limit => self.max_cpu_count, :max_memory_limit => statistic_value_in_gb(self.max_memory), :max_size_limit => statistic_value_in_gb(max_size), :cpus_overusage => 150, :memory_overusage => 150, :size_overusage => 150}
	end

	def libvirt_max_values    
		max_size = 0    
		for storage_pool in self.storage_pools
			max_size += storage_pool.capacity.to_i
		end     
		return {:max_cpus_limit => self.max_cpu_count, :max_memory_limit => statistic_value_in_gb(self.max_memory), :max_size_limit => statistic_value_in_gb(max_size), :cpus_overusage => 150, :memory_overusage => 150, :size_overusage => 150}
	end

	def vmware_max_values 
		max_size = 0
		for datastore in datastores
			max_size += datastore.capacity.to_i
		end 
		return {:max_cpus_limit => self.max_cpu_count, :max_memory_limit => statistic_value_in_gb(self.max_memory), :max_size_limit => statistic_value_in_gb(max_size), :cpus_overusage => 150, :memory_overusage => 150, :size_overusage => 150}
	end


end