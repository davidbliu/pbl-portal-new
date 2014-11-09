module EventsHelper

  def pbl_events_calendar_id
    '8bo2rpf4joem2kq9q2n940p1ss@group.calendar.google.com'
  end

  def process_google_events(events, options={})
    results = []
    events.each do |event|
      # some events dont have start and end times?
      if event.start and event.end
        start_time = google_datetime_fix(event.start)
        end_time = google_datetime_fix(event.end)

        if options[:this_week]
          start_time = this_week(start_time)
          end_time = this_week(end_time)
        end

        results << {
          id: event.id,
          summary: event.summary,
          start_time: start_time,
          end_time: end_time,
        }
      else
        p event
      end
    end

    return results.sort_by {|event| event[:start_time]}
  end

  def google_datetime_fix(datetime)
    time_string = datetime.date_time ? datetime.date_time.to_s : datetime.date.to_s
    DateTime.parse(time_string)
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    # css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to title, :sort => column, :direction => direction
  end

end
