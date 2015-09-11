namespace :points do
  task :pull => :environment do 
    ParseEvent.pull_from_google
  end
end
