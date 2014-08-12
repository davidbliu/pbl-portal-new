Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
  CLIENT_ID = "158145275272-lj3m0j741dj9fp50rticq48vtrfu59jj.apps.googleusercontent.com"
  CLIENT_SECRET = "XvvJaFO2t2lD0mEzNdya6NgT"
  provider :google_oauth2, CLIENT_ID, CLIENT_SECRET, {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email
            https://www.googleapis.com/auth/calendar
            https://www.googleapis.com/auth/plus.login',
    # redirect_uri: 'http://dry-bayou-7645.herokuapp.com/auth/google_oauth2/callback'
    # redirect_uri:'http://ucbpblmp-staging.herokuapp.com/auth/google_oauth2/callback'
    redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback'
    # redirect_uri: 'http://portal.berkeleypbl.com/auth/google_oauth2/callback'
    # redirect_uri: 'http://localhost:'
  }

end