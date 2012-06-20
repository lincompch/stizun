class JobRepetition < ActiveRecord::Base
	has_one :job_configuration

	def short_name
		return "ID #{id}: #{minute or '*'} #{hour or '*'} #{dom or '*'} #{month or '*'} #{dow or '*'}"
	end	
end
