class CreateComputeResourceStatistics < ActiveRecord::Migration
  def change
    create_table :compute_resource_statistics do |t|
      t.integer :compute_resource_id
      t.integer  :used_cpus
      t.float  :used_memory
      t.float  :used_size
      t.timestamps
    end
  end
end
