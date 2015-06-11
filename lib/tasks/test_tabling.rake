
namespace :test do
	namespace :tabling do
	  task :commitments_not_nil => ["db:test:set_test_env", :environment] do
		  puts Member.all.length.to_s + ' members in the database'
	  end

	  # should be able to specify times and members and have tabling slots generated for you
	  task :generate_assignments_basic => ["db:test:set_test_env", :environment] do
	  	g_100_members
	  	assignmentSuite = GenerateAssignmentsSuite.new
	  	assignmentSuite.generate_assignments_basic
	  end
	end
end

namespace :db do
  namespace :test do
	desc "Custom dependency to set test environment"
	task :set_test_env do # Note that we don't load the :environment task dependency
	  Rails.env = "test"
	end
  end
end 

class GenerateAssignmentsSuite
	def generate_assignments_basic
		puts 'generate_assignments_basic: basic assignment generation testing'
		begin
			times = 1..20
			members = Member.all.to_a
			assignments = TablingManager.generate_tabling_assignments(times, members)

			if not assignments
				puts "\t failed: assignments is nil"
			else
				puts "\t passed: assignments is not nil"
			end

		rescue => error
			p '*** FAILED basic_generate_assignments ***'
			p error
			return false
		end
	end
end

class TestSuite
""" runs tests 
each method run either succeeds or rails with some error message for what test was run and if it succeeded or not 
"""
end

