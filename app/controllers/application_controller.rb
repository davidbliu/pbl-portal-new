class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # include SessionsHelper
  include AuthHelper
  # include GoogleApiHelper
  include CalendarsHelper
  include TasksHelper
  # include EventsHelper
  include CacheHelper
  before_filter :current_member 
  

  def send_email
    puts ENV['GMAIL_USERNAME']
    puts ENV['GMAIL_PASSWORD']
    LinkNotifier.send_signup_email
    render nothing: true, status: 200
  end

  def calendar_pull
    cal = Google::Calendar.new(:client_id     => ENV['GOOGLE_INSTALLED_CLIENT_ID'], 
                           :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
                           :calendar      => GoogleEvent.pbl_events_calendar_id,
                           :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
                           )
  cal.login_with_refresh_token(ENV['REFRESH_TOKEN'])
  now = Time.now.utc
    start_min = Time.now-4.months
    start_max = start_min + 1.week
    @google_events = cal.find_events_in_range(start_min, start_max, :max_results=>1000)

    render 'layouts/google_events', :layout=>false
  end

  def clearcache
    """ clears all items from cache """
    Rails.cache.clear
    redirect_to root_path
  end
  
  def is_officer
    if current_member == nil
      redirect_to :controller=>'members',:action=>'not_signed_in'
    elsif not current_member.officer?
      redirect_to root_path
    end
  end
  
  # def is_approved
  #   if current_member == nil
  #     redirect_to :controller=>'members',:action=>'not_signed_in'
  #   elsif current_member.confirmation_status != 2
  #     current_member.confirmation_status = 1
  #     current_member.save
  #     redirect_to :controller=> 'members', :action=>'wait'
  #   end
  # end

  def is_admin
    if current_member == nil or not current_member.admin?
      redirect_to :controller=> 'members', :action=>'no_permission'
    end
  end


  # def current_member
  # 	return Member.where(name: "David Liu").first
  # end

  # Controller Helpers

  # Roughly the first day of instruction for fall
  # Basically, find the last Thursday of August
  def beginning_of_fall_semester
    week = 4

    date = Chronic.parse("#{week}th thursday last august")
    while date
      week += 1
      date = Chronic.parse("#{week}th thursday last august")
    end

    Chronic.parse("#{week - 1}th thursday last august").to_datetime
  end

  # Get the date of the next indicated weekday
  def date_of_next(day)
    date  = Date.parse(day)
    delta = date > Date.today ? 0 : 7
    date + delta
    Chronic.parse("0 next #{day}").to_datetime
  end

  # Date of the tabling start day
  def tabling_start
    if DateTime.now.cwday > 5 # If past Friday
      Chronic.parse("0 this monday")
    elsif DateTime.now.cwday == 1 # If Monday
      Chronic.parse("0 today")
    else
      Chronic.parse("0 last monday")
    end
  end

  # Date of ending tabling
  def tabling_end(length=5)
    tabling_start + length.days
  end

  def to_datetime(day, time)
    hour = time.to_i/100

    datetime = date_of_next(day).change(offset: "-0700") + hour.hours
    return datetime
  end

  # TEMPORARY fix for all day events
  def this_week(datetime)
    Chronic.parse("#{datetime.strftime("%H:%M")} this #{datetime.strftime("%A")}").to_datetime
  end

  
end
