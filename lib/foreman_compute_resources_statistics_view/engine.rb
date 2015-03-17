require 'deface'
require 'foreman_compute_resources_statistics_view'
require 'deface'

module ForemanComputeResourcesStatisticsView
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inhereits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    config.to_prepare do
      ComputeResource.send :include, ComputeResourceStatisticMethods

      Api::V2::ComputeResourcesController.send :include, ComputeResourcesStatisticsApis  # This is to include statistics colum in compute resource show API. This will override show action Api::V2::ComputeResourcesController
      
      if SETTINGS[:version].to_s.to_f >= 1.2
        # Foreman 1.2
        Host::Managed.send :include, HostComputeResourceCapacityValidator
      else
        # Foreman < 1.2
        Host.send :include, HostComputeResourceCapacityValidator
      end  
    end

    initializer 'foreman_compute_resources_statistics_view.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_compute_resources_statistics_view do
      end 
      app.config.paths['db/migrate'] += ForemanComputeResourcesStatisticsView::Engine.paths['db/migrate'].existent       

    end

    initializer 'foreman_compute_resources_statistics_view.helper' do |app|
      ActionView::Base.send :include, ForemanComputeResourcesStatisticsView::ComputeResourcesHelper
    end

  end
end
