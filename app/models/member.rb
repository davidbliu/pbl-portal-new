# == Schema Information
#
# Table name: members
#
#  id             :integer          not null, primary key
#  provider       :string(255)
#  uid            :string(255)
#  name           :string(255)
#  remember_token :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  old_member_id  :integer
#

# == Description
#
# A member of the Portal
#
# == Fields
# - provider: the authorization provider
# - uid: ID of member for the provider
# - name: name of member
# - remember_token: session token
#
# == Associations
#
# === Belongs to:
# - OldMember
#
# === Has Many:
# - CommitteeMember
# - Committee
# - TablingSlotMember
# - TablingSlot
# - Commitment
# - CommitmentCalendar
# - EventMember
# - Reimbursement
class Member < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :profile, :old_member_id, :remember_token, :confirmation_status

  validates :provider, :uid, :name, presence: true

  before_create :create_remember_token

  has_many :tabling_slot_members, dependent: :destroy
  has_many :tabling_slots, through: :tabling_slot_members

  has_many :committee_members, dependent: :destroy
  has_many :committees, through: :committee_members

  # has_many :commitment_calendars, dependent: :destroy

  has_many :event_members, dependent: :destroy

  # has_many :reimbursements, dependent: :destroy

  has_many :commitments, dependent: :destroy

  has_many :points, dependent: :destroy

  # has_many :likes

  belongs_to :old_member

  # scope :current_member
  # scope :in_committee, ->(c) {where(committees.first == c)}
  # scope :current_semester, -> {where(self.event.semester == Semester.current_semester)}
  # TODO: store in DB
  def primary_committee
    # self.committees.first
    self.committees.first
  end

  #
  # returns all alum (people who aren't in a committee this semester). GM committee is 1
  #
  def self.alumni
    in_a_committee_ids = CommitteeMember.where(semester: Semester.current_semester).pluck(:member_id)
    return Member.where('id NOT IN (?)', in_a_committee_ids)
  end

  def self.currently_in_committee(committee, semester = Semester.current_semester)
    # cms = Member.where(committees)
    current_committee_members = CommitteeMember.where(semester_id: semester.id).where(committee_id: committee.id).pluck(:member_id)
    return Member.where('id IN (?)', current_committee_members)
  end

  def self.current_gm_ids(semester = Semester.current_semester)
    # ids = Member
    gm_id = Committee.find(1)
    gm_ids = CommitteeMember.where(committee_id: gm_id).where(semester_id: semester.id).pluck(:member_id)
  end

  #
  # excludes gms
  #
  def self.current_members(semester = Semester.current_semester)
    current_committee_member_ids = CommitteeMember.where(semester_id: semester.id).pluck(:member_id)
    return Member.where('id IN (?)', current_committee_member_ids).where('id NOT IN (?)', Member.current_gm_ids)
  end

  def self.current_chairs(semester = Semester.current_semester)
    chair_exec_tier = CommitteeMemberType.where("tier > 1").pluck(:id)
    chair_ids = CommitteeMember.where(semester: semester).where('committee_member_type_id IN (?)', chair_exec_tier).pluck(:member_id)
    return Member.where('id IN (?)', chair_ids)
  end

  def self.current_cms(semester = Semester.current_semester)
    chair_exec_tier = CommitteeMemberType.where("tier > 1").pluck(:id)
    chair_ids = CommitteeMember.where(semester: semester).where('committee_member_type_id IN (?)', chair_exec_tier).pluck(:member_id)
    current_committee_member_ids = CommitteeMember.where(semester_id: semester.id).pluck(:member_id)
    return Member.where('id IN (?)', current_committee_member_ids).where('id NOT IN (?)', Member.current_gm_ids).where('id NOT IN (?)', chair_ids)
  end

  def current_committee(semester = Semester.current_semester)
    committee = self.committees.first
    cm = CommitteeMember.where(member_id: self.id).where(semester_id: semester.id)
    if cm.length > 0
      if Committee.where(id: cm.first.committee.id).length > 0
        committee= Committee.where(id: cm.first.committee.id).first
      end
    end
  end


  # returns all members that are currently part of pbl (as in CMS or officers or execs)
  # some extra logic for secretary to be able to mark anyone not just his own committee
  #
  # TODO NO LOOPS
  #
  # def self.current_members
  #   all_current_members = Array.new
  #   Member.find_each do |member|
  #       # if chair or exec
  #       if member.position == "chair" or (member.current_committee and member.current_committee.id == 2)
  #           all_current_members << member
  #       elsif member.current_committee and not member.current_committee.name.include? "General"
  #         all_current_members << member
  #       end
  #   end
  #   return all_current_members
  # end


  # Position of the member.
  # If no committee is given, returns the position for its #primary_committee.
  # Returns nil if the member does not belong to the committee, or it does not have a committee.
  #
  # === Parameters
  # - committee: the Committee to look up the position under; defaults to #primary_committee
  def position(semester = Semester.current_semester, committee=self.current_committee)
    if committee
      committee_member = self.committee_members.where(
        committee_id: committee.id).where(
        semester_id: semester.id
      ).first

      committee_member.committee_member_type.name if committee_member
    end
  end

  # Tier of the member
  # If no committee is given, returns the tier for its #primary_committee.
  # Returns nil if the member does not belong to the committee, or it does not have a committee.
  #
  # === Parameters
  # - committee: the Committee to look up the tier under; defaults to #primary_committee
  def tier(semester = Semester.current_semester, committee=self.primary_committee)
    if committee
      committee_member = self.committee_members.where(
        committee_id: committee.id).where(
        semester_id: semester.id
      ).first

      committee_member.committee_member_type.tier if committee_member
    end
  end

  # Admin status of the member.
  # TODO only if currently an exec
  def admin?
    self.name == "Keien Ohta" or self.name == "David Liu" or (self.current_committee and self.current_committee.name.include? "Exec")
     #or self.committees.include?(Committee.where(name: "Executive").first)
  end

  def secretary?
    self.name == "Michael Xu" or self.name == "David Liu"
  end
  # Officer status of the member.
  def officer?
    self.admin? or
    self.position == "chair"
  end

  # returns url of profile image. if none return path to blank.png
  def profile_url
    if self.profile and self.profile != ""
      return self.profile
    end
    return "/blank.png"
  end

  # Returns the relationships between itself and a given TablingSlot.
  #
  # === Parameters
  # - tabling_slot: a TablingSlot
  def tabling_slot_member(tabling_slot)
    self.tabling_slot_members.where(tabling_slot_id: tabling_slot.id).first
  end

  # Ininialize itself with some OmniAuth information
  #
  # === Parameters
  # - provider: the authentication service provider
  # - uid: the ID of the member under the provider
  def self.initialize_with_omniauth(provider, uid)
    Member.where(provider: provider, uid: uid).first_or_initialize
  end

  # The other Members that are part of this member's committees
  def cms(semester = Semester.current_semester)
    mem_ids = self.current_committee.cms.pluck(:member_id)
    return Member.where('id IN (?)', mem_ids)
  end

  # Create a new session token.
  def Member.new_remember_token
    SecureRandom.urlsafe_base64
  end

  # Encrypt the token.
  def Member.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end


  def attended_events(semester = Semester.current_semester)
    # p EventMember.where(member_id: self.id).length
    begin
      event_ids = EventMember.where(member_id: self.id).pluck(:event_id)
      return Event.where('id IN (?)', event_ids)
    rescue
      p 'failed'
    end
  end

  #
  # for each event add boolean for attended or not
  #
  def attendance_mapping(events)
    attended_ids = self.attended_events.pluck(:id)
    return events.map{|e| attended_ids.include? e.id}
  end

  #
  # for each event adds id of event if attended or nil if not
  #
  def attendance_id_mapping(events)
    attended_ids = self.attended_events.pluck(:id)
    return events.map{|e| {'id'=>e.id,'attended'=> (attended_ids.include? e.id ) }}
  end

  # Checks attendance for an event.
  #
  # === Parameters
  # - event: an event with an id
  def attended?(event)
    !self.event_members.where(event_id: event.id).empty?
  end

  # Helper for displaying itself in autocomplete forms.
  def autocomplete_display
    committee_name = self.committees.first ? self.committees.first.name : "N/A"

    "#{self.name}; #{committee_name}: #{self.position || "Member"}"
  end

  # Find matches on the main site using last name and email
  def find_old_members
    old_members = OldMember.where(
      "lower(last_name) = :last_name",
      last_name: self.name.split[-1].downcase,
    )

    return old_members
  end

  #
  # update member based on secretary's approval
  #
  def update_from_secretary(committee, position_id, position_name)
    committee_type = CommitteeType.committee
    if position_id == 0
      committee_type = CommitteeType.general
      cm_type = CommitteeMemberType.gm
    elsif position_id == 1
      committee_type = CommitteeType.committee
      cm_type = CommitteeMemberType.cm
    elsif position_id == 2
      committee_type = CommitteeType.committee
      cm_type = CommitteeMemberType.chair
    elsif position_id == 3
      committee_type = CommitteeType.admin
      cm_type = CommitteeMemberType.exec(position_name)
    end
    self.add_to_committee(committee.name, committee_type, cm_type)
  end
  # Update member information through the main site
  def update_from_old_member
    if self.old_member
      old_member = self.old_member

      # If this member is a committee member
      if old_member.tier_id == 3

        name = old_member.position.chomp("Committee Member").strip
        committee_type = CommitteeType.committee
        cm_type = CommitteeMemberType.cm

      # If this member is a committee chair
      elsif old_member.tier_id == 4

        name = old_member.position.chomp("Chair").strip
        committee_type = CommitteeType.committee
        cm_type = CommitteeMemberType.chair

      # If this member is an executive
      elsif old_member.tier_id == 5

        name = "Executive"
        committee_type = CommitteeType.admin
        cm_type = CommitteeMemberType.exec(old_member.position)

        # Exit with nil if the correct cm_type was not found
        return nil if cm_type.nil?

      # If this member is a general member
      elsif old_member.tier_id == 2

        name = "General Members"
        committee_type = CommitteeType.general
        cm_type = CommitteeMemberType.gm

      end

      self.add_to_committee(name, committee_type, cm_type)

      # Remove from any general committees unless the member belongs there
      self.remove_from_general unless old_member.tier_id == 2

      return self.save
    end
  end


  # Add member to the committee (creating the committee if it doesn't exist) as the given
  # committee member type, if he isn't part of the committee already
  # TODO semester?
  def add_to_committee(committee_name, committee_type, cm_type, semester = Semester.current_semester)
    # Find or create committee
    committee = Committee.where(
      name: committee_name,
    ).first_or_create!

    # Set the committee type
    committee.committee_type = committee_type
    committee.save!

    # remove self from current committees (david)
    self.committee_members.where(
      # committee_id: committee.id,
      semester_id: semester.id,
    ).destroy_all

    # Add member to committee if not already
    committee_member = self.committee_members.where(
      committee_id: committee.id,
      semester_id: semester.id,
    ).first_or_create!

    # Set the committee_member type
    committee_member.committee_member_type = cm_type
    committee_member.save!
  end

  # Remove from the general committee, if put in a regular committee.
  # Done by default when adding to a regular committee.
  def remove_from_general
    # Get general committees (may be more than one)
    general = Committee.where(
      committee_type_id: CommitteeType.general.id
    )

    # If this member is in the general members group (tested using set difference)
    if (general - self.committees).empty?
      general.each do |committee|
        self.committees.delete(general)
      end
    end
  end

  # Calculate the total number of points this member has
  def total_points(semester = Semester.current_semester)
    if semester == 'all'
      curr_events = Event.pluck(:id).collect{|i| i.to_s}
    else
      curr_events = Event.where(semester: semester).pluck(:id).collect{|i| i.to_s}
    end
    # events = EventMember.joins('INNER JOIN events ON CAST(events.id AS varchar) = event_members.event_id').where(member_id: self.id).pluck(:event_id)
    events_attended = EventMember.where('event_id IN (?)', curr_events).where(member_id: self.id).pluck(:event_id)
    return EventPoints.where('event_id IN (?)', events_attended).sum(:value)
  end

  # Return all attended tabling slots
  def attended_slots
    # self.tabling_slot_members.where(status_id: Status.where(name: :attended).first).map do |tsm|
    #   tsm.tabling_slot
    # end
    return self.tabling_slot_members.where(status_id: Status.where(name: :attended).first).pluck(:tabling_slot)
  end

  private

    def create_remember_token
      self.remember_token = Member.encrypt(Member.new_remember_token)
    end

end
