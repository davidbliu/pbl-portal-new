module CalendarsHelper

  # Helper for formatting the URI-incompatible Google calendar ID
  def format_google_calendar_id(id)
    id.split('.').join('-dot-').split('@').join('-at-')
  end

  # Revert a formatted Google calendar ID to one that is usable with the API
  def revert_google_calendar_id(id)
    id.split('-dot-').join('.').split('-at-').join('@')
  end

  def time_to_string(time)
  	if time
  		utc_time = Time.iso8601(time)
  		t = utc_time+ Time.zone_offset("PDT")
		return t.strftime("%l:%M %p %a %m/%d/%y")
	end
	return ''
  end

end
