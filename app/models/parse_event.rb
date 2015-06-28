class ParseEvent < ParseResource::Base
  fields :name, :location, :start_time, :end_time, :description, :points, :google_id, :type

  validates_presence_of :name

end