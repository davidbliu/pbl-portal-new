class ParseGroup < ParseResource::Base
  fields :name, :member_emails, :type

  def self.import
  	emails = Array.new
  	emails << "davidbliu@gmail.com"
  	emails << "nathalie.nguyen@berkeley.edu"
  	emails << "eric.quach@berkeley.edu"
  	name = "NED"
  	ParseGroup.create(name:name, member_emails: emails)
  end
end