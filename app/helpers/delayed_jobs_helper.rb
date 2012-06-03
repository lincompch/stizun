module DelayedJobsHelper

	def human_readable_job_name(job)
		argument_string = job['arguments'].join(",")
		return "#{job['class']}.#{job['method']}('#{argument_string}')"
	end

	def jobs_to_options(jobs)
		options = []
		jobs.each_with_index do |j, i|
			options << [human_readable_job_name(j), i]
		end
		return options_for_select(options)
	end


end