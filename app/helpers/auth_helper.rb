module AuthHelper
	
  def current_member
    """ remember token is just the current users email""" 
    my_email = cookies[:remember_token]
    # my_email = "alice.sun@berkeley.edu"
    # my_email = 'davidbliu@gmail.com'
    # @current_member ||= ParseMember.where(email: my_email).first if cookies[:remember_token]
    if my_email == nil or my_email == ''
      return nil
    end
    if SecondaryEmail.valid_emails.include?(my_email)
      return SecondaryEmail.email_lookup_hash[my_email]
    end
    return nil
  end

  def not_signed_in
    'members/not_signed_in'
  end

  def no_account
    'members/no_account'
  end

  def current_member_email
    cookies[:remember_token]
  end

  def sign_out
    @current_member = nil
    cookies[:remember_token] = nil
  end

end
