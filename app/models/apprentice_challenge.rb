class ApprenticeChallenge < ActiveRecord::Base
  # attr_accessible :event_id, :first_place, :second_place, :third_place, :name
  belongs_to :event
end
