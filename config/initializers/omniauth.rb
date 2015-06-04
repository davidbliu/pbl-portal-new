Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/calendar
            https://www.googleapis.com/auth/plus.login',
    # redirect_uri: 'http://dry-bayou-7645.herokuapp.com/auth/google_oauth2/callback'
    # redirect_uri:'http://ucbpblmp-staging.herokuapp.com/auth/google_oauth2/callback'
    # redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback'
    redirect_uri: 'http://'+ENV['HOST']+'/auth/google_oauth2/callback'
    # redirect_uri: 'http://portal.berkeleypbl.com/auth/google_oauth2/callback'
  }

end