class BlogNotifier < ActionMailer::Base
  default from: "berkeleypbl.webdev@gmail.com"

  # send a signup email to the user, pass in the user object that   contains the user's email address

  def send_blog_email(members=['davidbliu@gmail.com'], post)
    @post = post
    mail( :to => members.join(','),
    :subject => 'PBL Blog: ' + post.title ).deliver
  end



end