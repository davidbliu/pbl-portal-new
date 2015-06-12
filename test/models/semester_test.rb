require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

	test 'there should be a current semester' do 
		assert Semester.current_semester
	end

	test 'current semester should be most recent semester by start date' do 
		assert Semester.current_semester.name == 'fall 2015'
	end
end