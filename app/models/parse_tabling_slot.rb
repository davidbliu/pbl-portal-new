class ParseTablingSlot < ParseResource::Base
  fields :time, :member_emails, :day, :hour

  def get_member_emails
    self.member_emails and self.member_emails != '' ? self.member_emails.split(',') : []
  end

  def to_json
  	return {'time'=> self.time, 'member_emails'=>self.member_emails.split(',')}
  end

end
