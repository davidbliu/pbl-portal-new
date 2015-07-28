# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

set :output, {:error => 'error.log', :standard => 'cron.log'}

RAILS_ROOT = ENV['RAILS_ROOT']
every 10.minutes do
  # command "/usr/bin/some_great_command"
  command "cd #{RAILS_ROOT} && source setenv.sh && rake elasticsearch:reindex"
  command "echo 'hi there reindexing golinks'"
  # rake "some:great:rake:task"
end

every 7.hours do
  command "cd #{RAILS_ROOT} && source setenv.sh && rake elasticsearch:scrape"
  command "echo 'hi there scraping golink documents!'"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
