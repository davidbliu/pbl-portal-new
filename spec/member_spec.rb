require 'spec_helper'

describe Member do
	before :each do 
		@member = Member.new(name: 'david liu', 
							email: 'test_email@gmail.com')
	end

	describe '#new' do
		it 'returns a new member object' do
			@member.should(be_an_instance_of(Member))
		end
		it 'doesnt create more than one member object' do
			p Member.all.length 
			p 'that was the number of members total'
		end
	end

end