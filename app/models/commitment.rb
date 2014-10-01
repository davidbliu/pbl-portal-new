# == Schema Information
#
# Table name: commitments
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  summary    :string(255)
#  start_time :datetime
#  end_time   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# A segment of time that represents a time commitment of some kind for a Member.
#
# == Fields
# - summary: a short description of the commitment
# - start_time: starting time
# - end_time: ending time
#
# == Associations
#
# === Belongs to
# - Member

class Commitment < ActiveRecord::Base
  # attr_accessible :end_time, :member_id, :start_time, :summary, :start_hour, :end_hour, :day

  belongs_to :member
end
