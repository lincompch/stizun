class AddRunAtToJobConfigurations < ActiveRecord::Migration
  def change
  	add_column :job_configurations, :run_at, :datetime
  end
end
