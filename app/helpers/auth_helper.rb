module AuthHelper
	
  def current_member
    """ remember token is just the current users email""" 
    my_email = cookies[:remember_token]
    # my_email = "alice.sun@berkeley.edu"
    @current_member ||= ParseMember.where(email: my_email).first if cookies[:remember_token]
  end

  def sign_out
    @current_member = nil
    cookies[:remember_token] = nil
  end

end
