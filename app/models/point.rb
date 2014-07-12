# == Schema Information
#
# Table name: points
#
#  id         :integer          not null, primary key
#  member_id  :integer          not null
#  value      :integer          not null
#  details    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# A Member earning points for something.
#
# == Fields
# - value: amount of points
# - details: what they earned it for
#
# == Associations
#
# === Belongs to:
# - Member
class Point < ActiveRecord::Base
  attr_accessible :details, :member_id, :value

  belongs_to :member
end
