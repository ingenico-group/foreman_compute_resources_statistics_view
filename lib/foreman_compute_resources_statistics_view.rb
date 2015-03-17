require 'foreman_compute_resources_statistics_view/engine'
require 'rails'
module ForemanComputeResourcesStatisticsView
	class Railtie < Rails::Railtie
		railtie_name :foreman_compute_resources_statistics_view

		#rake_tasks do
		#	load "tasks/compute_resource_statistics.rake"
		#end
	end
end
