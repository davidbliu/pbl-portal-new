# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  first_name                :string(255)
#  last_name                 :string(255)
#  sex                       :boolean
#  email                     :string(255)
#  position                  :string(255)
#  phone                     :string(255)
#  aim_sn                    :string(255)
#  facebook                  :string(255)
#  twitter                   :string(255)
#  youtube                   :string(255)
#  portrait                  :string(255)
#  graduation                :datetime
#  major                     :string(255)
#  hometown                  :string(255)
#  blurb                     :text
#  is_alum                   :boolean          default(FALSE)
#  is_paid                   :boolean          default(FALSE)
#  last_activity_at          :datetime
#  preference_id             :integer
#  family_id                 :integer
#  created_at                :datetime
#  updated_at                :datetime
#  crypted_password          :string(40)
#  salt                      :string(40)
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  tier_id                   :integer          default(1)
#  portrait_mime_type        :string(255)
#  portrait_filesize         :string(255)
#  portrait_width            :string(255)
#  portrait_height           :string(255)
#  reset_code                :string(255)
#  cmap                      :string(255)
#  sort_priority             :integer          default(0)
#  linkedin                  :string(255)      default("")
#

require 'digest/sha1'

# == Description
#
# A member record in the main PBL site.
class OldMember < ActiveRecord::Base
  # include ::Authentication
  # include ::Authentication::ByPassword
  # include ::Authentication::ByCookieToken

  establish_connection(
    adapter:  "mysql2",
    database: "berkeleypbl2_production",
    encoding: "utf8",
    username: "ucbpbltesting",
    password: "ThinkBeforeYouDo",
    host:     "mysql.berkeleypbl.com",
  )

  self.table_name = "members"
  # attr_accessible :first_name, :last_name, :email, :tier, :password, :password_confirmation, :crypted_password, :salt, :tier_id, :phone
  # has_secure_password
  before_save :create_remember_token

  def has_password?(submitted_password)
    crypted_password == encrypt(submitted_password)
  end

  def authenticate(submitted_password)
    user = OldMember.find_by_email(self.email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  # NOTE: Don't know if these are even used....

  def full_name
    self.first_name + " " + self.last_name
  end

  def cms
    committee = self.position.split.first
    OldMember.where("position LIKE '#{committee} Committee Member'") unless self.tier_id > 4
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
