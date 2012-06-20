class JobConfigurationTemplate < ActiveRecord::Base
	has_one :job_configuration

	def short_name
		return "#{job_class}.#{job_method}( #{job_arguments} )"	
	end
end
