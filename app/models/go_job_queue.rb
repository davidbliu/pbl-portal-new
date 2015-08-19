require 'timeout'
class GoJobQueue < ParseResource::Base
	fields :type, :name, :time, :status, :timeout
	#timeouts are saved in seconds

	def self.test
		GoJobQueue.create(type:'elasticsearch:reindex', name:'test job', time:Time.now, status:'created', timeout: 60)
	end

	def execute_job
		puts 'running '+self.type
		self.status = 'running'
		self.save
		GoJobQueue.cancel_matching(self)

		system("source setenv.sh && rake " + self.type)

		self.status = 'completed'
		self.save
	end

	def self.cancel_matching(job)
		matching = GoJobQueue.limit(10000000).where(type: job.type, status: 'created').select{|x| x.id != job.id}
		GoJobQueue.destroy_all(matching)
	end

	def self.create_job(type)
		job = GoJobQueue.new(type:type, status:'created', time:Time.now)
		Thread.new{
			job.save
		}
	end

	def self.run_all_jobs
		jobs = GoJobQueue.limit(100000).where(status:'created')
		seen = Array.new
		jobs.each do |job|
			if not seen.include?(job.type)
				seen << job.type
				Thread.new{
					job.execute_job
				}
			end
		end
	end

end