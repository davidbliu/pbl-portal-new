namespace :fixtures do
  desc "generate fixtures for testing purposes"
  task :members => ["db:test:set_test_env", :environment] do
  	g_100_members
  end

  task :events => ["db:test:set_test_env", :environment] do
	  g_100_events
  end

  task :all => ["db:test:set_test_env", :environment] do
    g_100_members
    print_banner
    g_100_events
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



def print_banner
  p '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
end

def g_commitments(i)
  commitments = Array.new
  (0..167).each do |ind|
    if !(i..i+20).include? ind
      commitments << 0
    else
      commitments << 1
    end
  end
  return commitments
end

def g_100_members
	p 'generating 100 member fixtures'
  Member.destroy_all
	(1..100).each do |i|
		member = Member.new
		member.name = 'Test Member '+i.to_s
		member.email = 'test_member'+i.to_s+'@testing.com'
    member.provider = 'google'
    member.uid = 'uid'+member.id.to_s
    member.commitments = g_commitments(i)
		member.save!
	end
	p 'there are now '+Member.all.length.to_s+' members'
end

def g_100_events
  p 'generating 100 event fixtures'
  Event.destroy_all
  (1..100).each do |i|
    event = Event.new
    event.name = "test_event"+i.to_s
    event.points = i
    event.start_time = Time.local(2008, 7, 8) 
    event.save!
  end
  p 'there are now '+Event.all.length.to_s+' events'
end