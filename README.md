# foreman\_compute\_resources\_statistics\_view

A small plugin to showcase the awesome [Deface](https://github.com/spree/deface)
library. It simply adds a statistics to the ComputeResources list and properties table. It also
adds new max values and usage values statisticss to compute resources new/edit form where we can set the max cpus, memory and size and overusage of cups, memory and size of the compute resource. These values are used to display the statistics.

# Screenshots
![Statistics in Compute resource list page](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_compute_resources_statistics_view/comp-res-statistics-list-page.png)

![Statistics in Compute resource show page](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_compute_resources_statistics_view/Statistics-in-show-page.png)

![Statistics fields in Compute resource form](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_compute_resources_statistics_view/statistics-fields-to-comp-res-form.png)



# Installation

Require the gem in Foreman (you may need extra dependencies such as libxml or libxslt
to build the nokogiri dependency)

```yaml
gem 'foreman_compute_resources_statistics_view', :git => "https://github.com/ingenico-group/foreman_compute_resources_statistics_view.git"
```

Update Foreman with the new gems:

    bundle update foreman_compute_resources_statistics_view

# Post installation

After installing this gem we need to run the following rake task to setup the database

```yaml
rake compute_resource_statistics:add_columns RAILS_ENV=production 
```

This rake task will add `max_cpus_limit(integer)`, `max_memory_limit(float)`, `max_size_limit(float)`, `cpus_overusage(integer)`, `memory_overusage(float)`, `size_overusage(float)` columns to `compute_resources` table. These columns are required to calculate the statistics. After adding these columns this rake task will fetch the max values from the compute resource(like max_cpus, max_memory and max_size) and for over usage columns the default value is 150. These columns are also added to new/edit form of compute resources to update the exact values. This rake task will also create new table called `compute_resource_statistics` table to store the used values like used cpus, memory and size. These values are fetched from the compute resource.

To update the used values in compute_resource_statistics table please use below rake task(This can be ran using rake task so that it will display accurate values every time)

```yaml
rake compute_resource_statistics:update_used_statistics RAILS_ENV=production 
```


# Pre remove

If we want to remove this feature and remove all columns and table related to this feature. Please run below rake task and remove this gem from the Gemfile

```yaml
rake compute_resource_statistics:remove_columns RAILS_ENV=production 
```


# Configuration

Add below content to settings.yaml file 

```yaml
:compute_resource_statistics_view:
  :list_page:
    :title: Statistics
    :title_after: Name
    :content: usage_statistics
    :content_after: link_to compute.name
    :view: :compute_resources_list
  :show_page:
    :title: Statistics
    :after: compute_resource.provider_friendly_name
    :content: usage_statistics
    :view: :compute_resources_properties
  :edit_form:
    :view: :edit_statistic_values
    :after: compute_connection
```

`title` is an arbitrary string which is displayed as the statistics header. `content` is
a method call to the `ComputeResource` object, using `compute.send`.

In this `list_page` setting is used to display the statistics in compute resources list page and `show_page` is used to display statistics in compute resource show page and `edit_form` is used to display max value and usage value fields of CPUs, memory and size in new/edit form of compute resource. max and usage values are used to calculate the statistics to display.

You will need to restart Foreman for changes to take effect, as the `settings.yaml` is
only read at startup.

# Limitations

This gem will display statistics only for compute resources of types Ovirt, Libvirt and Vmware

# Copyright

Copyright (c) 2015 Ingenico
