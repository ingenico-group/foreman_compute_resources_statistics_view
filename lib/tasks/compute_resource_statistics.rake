namespace :compute_resource_statistics do

	desc 'Adde statistics max and overusage columns to compute resources'
	task :add_columns => :environment do  
		if !ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS.map{|s| s[0]}.all?{ |x| ComputeResource.column_names.to_a.include?(x) }
			puts "Adding max columns and overusage columns to compute_resources table"
			for statistics_max_column in ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS
				if ActiveRecord::Base.connection.column_exists?(:compute_resources, statistics_max_column[0].to_sym)
					ActiveRecord::Base.connection.remove_column(:compute_resources, statistics_max_column[0].to_sym)
				end
				ActiveRecord::Base.connection.add_column(:compute_resources, statistics_max_column[0].to_sym, statistics_max_column[1].to_sym)
			end
			
			puts "Creating compute_resource_statistics table"
			ENV['VERSION']= "20140624072921"
			Rake::Task['db:migrate:up'].invoke
			puts "Adding capacity validation column to compute_resources table"			
			Rake::Task['compute_resource_statistics:add_capacity_validation_column_to_compute_resources'].invoke
			puts "Updating max and overusage columns in compute_resources table"			
			Rake::Task['compute_resource_statistics:assign_default_values_to_max_overusage_columns'].invoke
		end
	end

	desc 'Assign default values to max and overusage columns in compute resources table'
	task :assign_default_values_to_max_overusage_columns => :environment do  
		ComputeResource.reset_column_information
		if ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS.map{|s| s[0]}.all?{ |x| ComputeResource.column_names.to_a.include?(x) }
			
			compute_resources = ComputeResource.where(:type => ComputeResource::COMPUTE_RESOURCE_TYPES_TO_HAVE_STATISTICS)
			for compute_resource in compute_resources
				begin
					puts "updating max and overusage columns of #{compute_resource.name}..."
					compute_resource.update_attributes(compute_resource.send("#{compute_resource.provider.downcase}_max_values"))
					puts "updated"
				rescue Exception => e
					puts "Exception while updating max and overusage values: #{e.message}"
				end
			end
			Rake::Task['compute_resource_statistics:update_used_statistics'].invoke
			
		end
	end

	desc 'Fetch compute resource statistics and store in database'
	task :update_used_statistics => :environment do  	
		if ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS.map{|s| s[0]}.all?{ |x| ComputeResource.column_names.to_a.include?(x) }
			compute_resources = ComputeResource.where(:type => ComputeResource::COMPUTE_RESOURCE_TYPES_TO_HAVE_STATISTICS)
			for compute_resource in compute_resources
				puts "updating used statistics for '#{compute_resource.name}'"
				begin
					compute_resource_statistic = compute_resource.compute_resource_statistic || ComputeResourceStatistic.create(:compute_resource_id => compute_resource.id)
					compute_resource_statistic.update_attributes(compute_resource.send("#{compute_resource.provider.downcase}_statistics").merge({ :updated_at => Time.now}))
				rescue Exception => e
					puts "Exception while updating '#{compute_resource.name}' used statistics: #{e.message}"
				end
			end
		else
			puts "No statistics columns are added. Please run rake compute_resource_statistics:add_columns"
		end
	end

	desc 'Remove compute resource statistics columns'
	task :remove_columns => :environment do
		puts "Removing max columns and overusage columns from compute_resources table"			
		for statistics_max_column in ComputeResource::COMPUTE_RESOURCE_STATISTICS_COLUMNS
			if ActiveRecord::Base.connection.column_exists?(:compute_resources, statistics_max_column[0].to_sym)
				ActiveRecord::Base.connection.remove_column(:compute_resources, statistics_max_column[0].to_sym)
			end			
		end
		puts "Deleting compute_resource_statistics table"			
		ENV['VERSION']= "20140624072921"
		Rake::Task['db:migrate:down'].invoke
	end

	desc 'Add capacity validation column to compute_resources table'
	task :add_capacity_validation_column_to_compute_resources => :environment do
		unless ActiveRecord::Base.connection.column_exists?(:compute_resources, ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym)
			ActiveRecord::Base.connection.add_column(:compute_resources, ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[0].to_sym, ComputeResource::COMPUTE_RESOURCE_CAPACITY_VALIDATION_COLUMN[1].to_sym, :default => false)
		end
	end

end