class LinkNotifier < ActionMailer::Base
  default from: "berkeleypbl.webdev@gmail.com"

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email
    mail( :to => 'davidbliu@gmail.com',
    :subject => 'Thanks for signing up for our amazing app' ).deliver
  end

  def send_reindex_email
  	@golinks  = GoLink.all
  	mail(:to => 'davidbliu@gmail.com',
    :subject => 'PBL Links has been re-indexed' ).deliver
  end
end
