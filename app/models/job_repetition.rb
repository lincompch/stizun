class JobRepetition < ActiveRecord::Base
	has_many :job_configurations

	def short_name
		return "ID #{id}: #{minute or '*'} #{hour or '*'} #{dom or '*'} #{month or '*'} #{dow or '*'}"
	end	
end
