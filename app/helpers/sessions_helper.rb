module SessionsHelper
	
  def current_member
    @current_member ||= ParseMember.where(remember_token: cookies[:remember_token]).first if cookies[:remember_token]
  end

  def sign_out
    @current_member = nil
    cookies[:remember_token] = nil
  end

end
