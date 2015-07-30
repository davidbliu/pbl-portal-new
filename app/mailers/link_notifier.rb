class LinkNotifier < ActionMailer::Base
  default from: "berkeleypbl.webdev@gmail.com"

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email
    mail( :to => 'davidbliu@gmail.com',
    :subject => 'Thanks for signing up for our amazing app' ).deliver
  end

  def send_reindex_email
  	@golinks  = GoLink.all
  	mail(:to => 'davidbliu@gmail.com,eric.quach@berkeley.edu,kvyinn@gmail.com',
    :subject => 'PBL Links has been re-indexed' ).deliver
  end

  def send_scrape_email
  	@scraped = ParseElasticsearchData.limit(100000).all
  	mail(:to => 'davidbliu@gmail.com,eric.quach@berkeley.edu,kvyinn@gmail.com',
    :subject => 'PBL Links has been re-scraped' ).deliver
  end

  def send_gdrive_scraped_email(messages, saved_urls)
    @saved_urls = saved_urls
    @messages = messages
    mail(:to => 'davidbliu@gmail.com',
    :subject => 'Google Drive Documents Scraped by PBL Machine' ).deliver
  end

  def send_memcached_email
    def dalli_client
      options = { :namespace => "app_v1", :compress => true }
      dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    end
    @num_keys = dalli_client.get('go_key_hash')
    mail(:to => 'davidbliu@gmail.com', :subject => 'Go Links Memcached').deliver
  end


end
