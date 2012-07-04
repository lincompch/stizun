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

	def print_handler_object(handler)
		h = YAML::load(handler)
		output =  h.object.to_s
		output += ".#{h.args[0]}"
		output += "(#{h.args[1]})"
		return output
	end


end