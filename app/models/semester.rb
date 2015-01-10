class Semester < ActiveRecord::Base
  attr_accessible :end_date, :name, :start_date
  # has_many :members, through: :semester_members
  # has_many :event_points
  has_many :committee_members, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :event_members, dependent: :destroy
  has_many :deliberations, dependent: :destroy


  def self.current_semester
    return Semester.order(:start_date).reverse.first
  end
end
