class ParseGroup < ParseResource::Base
  fields :name, :member_emails, :type

  def sync_emails
  	self.member_emails.each do |email|
  		puts email
  	end
  end

  def cache_groups
    dalli_client = DalliManager.dalli_client

    # hash from group id to group object
    groups = ParseGroup.limit(10000).all.to_a
    dalli_client.set('group_hash', groups.index_by(&:id))

  end

  
  def self.import
  	emails = Array.new
  	emails << "davidbliu@gmail.com"
  	emails << "nathalie.nguyen@berkeley.edu"
  	emails << "eric.quach@berkeley.edu"
  	name = "NED"
  	ParseGroup.create(name:name, member_emails: emails)
  end
end