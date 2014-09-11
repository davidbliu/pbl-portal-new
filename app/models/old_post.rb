

require 'digest/sha1'

# == Description
#
# A member record in the main PBL site.
class OldPost < ActiveRecord::Base
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

  self.table_name = "posts"
  attr_accessible :member_id, :title, :body, :tier
  # has_secure_password
  # before_save :create_remember_token

  # def has_password?(submitted_password)
  #   crypted_password == encrypt(submitted_password)
  # end

  # def authenticate(submitted_password)
  #   user = OldMember.find_by_email(self.email)
  #   return nil  if user.nil?
  #   return user if user.has_password?(submitted_password)
  # end

  # NOTE: Don't know if these are even used....

  # def full_name
  #   self.first_name + " " + self.last_name
  # end

  # def cms
  #   committee = self.position.split.first
  #   OldMember.where("position LIKE '#{committee} Committee Member'") unless self.tier_id > 4
  # end

  # private
  #   def create_remember_token
  #     self.remember_token = SecureRandom.urlsafe_base64
  #   end
end
