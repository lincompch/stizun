class JobConfigurationTemplate < ActiveRecord::Base
	has_many :job_configurations

	def short_name
		return "#{job_class}.#{job_method}( #{job_arguments} )"	
	end
end
