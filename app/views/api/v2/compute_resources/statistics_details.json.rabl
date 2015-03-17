object @compute_resource

extends "api/v2/compute_resources/show"

if @compute_resource.respond_to?(:max_cpus_limit) and @compute_resource.respond_to?(:max_memory_limit) and @compute_resource.respond_to?(:max_size_limit) and @compute_resource.respond_to?(:cpus_overusage) and @compute_resource.respond_to?(:memory_overusage) and @compute_resource.respond_to?(:size_overusage)
	attributes :max_cpus_limit, :max_memory_limit, :max_size_limit, :cpus_overusage, :memory_overusage, :size_overusage

	node do |c|
		if compute_resource_statistic = c.compute_resource_statistic
			{ :used_cpus => compute_resource_statistic.used_cpus, :used_memory => compute_resource_statistic.used_memory, :used_size => compute_resource_statistic.used_size,  :used_statistics_last_updated_at => compute_resource_statistic.updated_at}
		else
			{ :used_cpus => nil, :used_memory => nil, :used_size => nil, :used_statistics_last_updated_at => nil}	
		end
	end
end