class CreateJobConfigurations < ActiveRecord::Migration
  def up
  	create_table :job_configurations do |t|
  		t.integer :job_configuration_template_id
  		t.integer :job_repetition_id
  	end
  end

  def down
  end
end
