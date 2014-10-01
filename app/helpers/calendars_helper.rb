module CalendarsHelper

  # Helper for formatting the URI-incompatible Google calendar ID
  def format_google_calendar_id(id)
    id.split('.').join('-dot-').split('@').join('-at-')
  end

  # Revert a formatted Google calendar ID to one that is usable with the API
  def revert_google_calendar_id(id)
    id.split('-dot-').join('.').split('-at-').join('@')
  end

end
