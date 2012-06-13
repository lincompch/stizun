class CreateJobConfigurationTemplates < ActiveRecord::Migration
  def change
    create_table :job_configuration_templates do |t|
      t.string :job_class
      t.string :job_method
      t.text :job_arguments

      t.timestamps
    end
  end
end
