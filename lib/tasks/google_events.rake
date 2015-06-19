
namespace :events do
	task :pull_google_events  => :environment do
		pull_google_calendar_events
	end
end 