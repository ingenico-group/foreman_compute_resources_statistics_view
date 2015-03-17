module HostComputeResourceCapacityValidator

	extend ActiveSupport::Concern
	
	included do
		after_validation :validate_compute_resource_capacity
	end

	def validate_compute_resource_capacity		
		if (ComputeResource.column_names.include?(ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0]) and self.compute_resource and self.compute_resource.send(ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym)) and self.compute_resource.can_have_statistics? and resource_statistic = self.compute_resource.compute_resource_statistic
			overused_types = []
			for capacity_type in ["cpus", "memory", "size"]
				used_value = resource_statistic.send("used_"+capacity_type).to_f.round(2)
				max_value = self.compute_resource.send("max_"+capacity_type+"_limit").to_f.round(2)
				overusage = self.compute_resource.send(capacity_type+"_overusage").to_f.round(2)
				if overusage_value = ((max_value/100.to_f)*overusage) and  used_value > overusage_value					
					overused_types << capacity_type					
				end
			end
			errors.add(:compute_resource_id, _("#{overused_types.join(', ')} #{overused_types.length == 1 ? 'is' : 'are' } already over used")) if !overused_types.empty?
		end
	end

end