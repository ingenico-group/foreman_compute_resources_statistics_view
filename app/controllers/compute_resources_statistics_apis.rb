module ComputeResourcesStatisticsApis

	def self.included(base)
		base.class_eval do
			def show_with_statistics_details
				#@compute_resource = ComputeResource.find(params[:id])
				render :action => "statistics_details"
			end
			base.alias_method_chain(:show, :statistics_details)
		end		
	end

end