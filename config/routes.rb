Dockernotes::Application.routes.draw do

  get "/sign_out", to: "auth#sign_out"
  # get "/auth/google_oauth2/callback", to: "sessions#sign_onto_google"



  # get "/pull_google_events", to: "events#pull_google_events"
  root 'members#home'

  get '/clearcache', to: 'application#clearcache'

  get '/go', to: 'go#homepage'
  get '/go/manage', to: 'go#manage'
  get '/go/add', to:'go#add'
  post '/go/create', to: 'go#create'
  # get '/go/create', to: 'go#create'
  get '/go/guide', to: 'go#guide'
  get '/go/catalogue', to: 'go#catalogue'
  get '/go/clicks', to: 'go_link_clicks#index'
  get '/go/json', to: 'go#json'
  get  '/go/:id/edit', to: 'go#edit'
  post '/go/:id/update', to: 'go#update'
  get '/go/:id/destroy', to: 'go#destroy'
  get '/go/reindex', to: 'go#reindex'
  get '/go/:id/member_links', to: 'go#member_links' # what links has this member created
  get '/go/directories', to: 'go#directories'
  get '/go/clearcache', to: 'go#clearcache'
  get '/go/:key/metrics', to: 'go#metrics'
  get '/go/cwd', to: 'go#cwd'
  get '/:key/go', to: 'go#index'
  get '/go/affix', to: 'go#affix'
  get '/go/:url/lookup', to: 'go#lookup'
  get '/go/lookup', to: 'go#lookup'
  get 'go/favorite', to: 'go#favorite'
  get 'go/search', to: 'go#search'
  get 'go/admin', to: 'go#admin' #admin main dashboard
  get 'go/tags', to: 'go#tag_catalogue'
  post 'go/update_rank', to:'go#update_rank'
  post 'go/delete_link', to: 'go#delete_link'
  post 'go/update_link', to: 'go#update_link'
  get 'go/collections/:name', to: 'go#show_collection'
  get 'go/collections', to: 'go#collections'
  get 'go/load_tag_catalogue', to:'go#load_tag_catalogue'
  get 'go/collections/:name/edit', to: 'go#edit_collection'
  post 'go/collections/:name/update', to: 'go#update_collection'
  post 'go/save_link', to: 'go#save_link'
  post 'go/delete_link', to:'go#delete_link'
  get 'go/homepage', to: 'go#homepage'
  """ me"""
  get 'go/bundles', to: 'go#bundles'
  get 'go/my_links', to:'go#my_links'
  get 'go/test', to:'go#test'


  """ new collections """
  get 'go/new_collections', to:'collections#index'
  get 'go/new_collections/:id', to:'collections#view_collection'
  get 'go/cache_collections', to:'collections#cache_collections'

  """ permissions testing routes"""
  post 'go/update_bundle_groups', to:'go#update_bundle_groups'
  get '/permissions', to:'go#permissions'
  get '/permissions/view_groups', to:'go#view_groups'
  get '/permissions/view_bundles_permissions', to:'go#view_bundles_permissions'


  """ chrome extension routes """
  post '/chrome/create_go_link', to: 'chrome_extension#create_go_link'
  get '/chrome/lookup_url', to: 'chrome_extension#lookup_url'
  get '/chrome/directories_dropdown', to: 'chrome_extension#directories_dropdown'
  post '/chrome/create_directory', to: 'chrome_extension#create_directory'
  get '/chrome/search', to: 'chrome_extension#search'
  post '/chrome/undo_create_go_link', to: 'chrome_extension#undo_create'
  get '/chrome/favorite_links', to: 'chrome_extension#favorite_links'
  get 'chrome/chrome_sync', to:'chrome_extension#chrome_sync' #sync chrome with the portal
  get 'chrome/my_bundles', to:'chrome_extension#my_bundles'
  post 'chrome/create_bundle', to: 'chrome_extension#create_bundle'
  get 'chrome/most_used_links', to: 'chrome_extension#most_used_links'
  get 'chrome/resolve_chrome_email', to: 'chrome_extension#resolve_chrome_email'
  get 'chrome/tracker', to: 'chrome_extension#tracker'

  """tasks routes """
  get '/tasks', to:'tasks#home'
  get '/tasks/clearcache', to: 'tasks#clearcache'
  get '/tasks/guide', to: 'tasks#guide'
  post '/tasks/update', to: 'tasks#update'
  get '/tasks/import', to: 'tasks#import'
  get '/tasks/update_trello_info', to: 'tasks#update_trello_info'
  get '/tasks/create', to: 'tasks#create'
  post '/tasks/create_task', to: 'tasks#create_task'
  get '/tasks/card/:id', to: 'tasks#card'
  get '/tasks/register_board', to: 'tasks#register_board'
  get '/tasks/board_cards/:board_id', to: 'tasks#board_cards'
  post '/tasks/add_comment/:card_id', to: 'tasks#add_comment'
  post '/tasks/update_description/:card_id', to:'tasks#update_description'
  post '/tasks/upload_attachment/:card_id', to:'tasks#upload_attachment'
  get '/tasks/pull_labels/:board_id', to: 'tasks#pull_labels'
  post '/tasks/update_labels', to: 'tasks#update_labels'

  """ push notifications """
  get '/push', to:'push#index'
  get '/pull_notifications', to: 'members#notifications'

  """ points routes """
  get '/pull_google_events', to: 'points#pull_google_events'

  """me routes"""
  get '/member/:email', to: 'members#member'

  get 'calendar_pull', to: 'application#calendar_pull'

  # email routes
  get 'send_email', to:'application#send_email'

  resources :google_events do 
    collection do 
      get 'google_calendar_redirect'
      get 'google_calendar_callback'
      get 'list_google_events'
      get 'sync_events'
    end
  end

  resources :members do
    member do
      get 'destroy'
      get 'edit'
      get 'update'
      get 'reconfirm'
      get 'edit_confirmation'
      post 'update_confirmation'
      get 'profile'
      post 'upload_profile'
    end
    collection do
      get 'manage'
      get 'all'
      get 'confirm_new' # secretary view to confirm new members
      post 'process_new'
      get 'sign_up'
      get 'complete_sign_up'
      get 'wait'
      get 'not_signed_in'
      get 'check' # mostly for debugging purposes
      get 'account'
      get 'update_account'
      get 'index_committee'
      get 'no_permission'
    end
  end


  get "/auth/google_oauth2/callback", to: "auth#google_callback"

  resources :auth do
    collection do
      get 'sign_up'
      get 'sign_in'

    end
  end

  resources :swipy do
    collection do
      get 'record_attendance'
      get 'record_event_member'
    end
  end

  resources :youtube do 
    collection do
      get 'sync'
      get 'text_sync'
      post 'process_text_sync'

      get 'resolve_tags'
      get 'set_priorities'
      post 'process_new_priorities'
      get 'get_youtube_sync_text' # get text to sync to youtube
      # for some reason wont work on remote
    end
  end

  resources :points do
    collection do
      get 'all_points' # display points for all semesters. like a master view
      get 'rankings'
      get 'mark_attendance'
      post 'update_attendance'
      get 'apprentice'
      get 'coocurrence'
    end

  end

  resources :event_members do 
    member do
      get 'destroy'
    end
  end
  resources :events do
    member do
      get 'delete'
      get 'attendance'
      get 'edit'
      get 'update'
      post 'update_points'
    end
    collection do
      get "pull_google_events"
      get "sync_google_events"
      get "list_google_events"
      get "list_events"
      get "delete_events"
      get 'create'
      get 'manage'
      get 'google_calendar_redirect'
      get 'google_calendar_callback'
    end
  end

  resources :deliberations do
    member do 
      get 'rankings'
      get 'results'
      get 'import_applicants'
      post 'update_applicants'
      get 'rank_applicants' # for chairs to rank applicants. pass in committee_id with ?
      get 'generate_default_rankings'
      post 'update_rankings'
      get 'settings'
      post 'update_settings'
      get 'add_applicant'
      post 'create_applicant'
    end
    collection do
      get 'manage'
    end
  end

  resources :applicants do
    member do
      get 'image'
      post 'upload_image'
      get 'update_payment'
    end
    # member do
    #   get 'edit'
    #   post 'update'
    #   # get 'show'
    # end
  end

  resources :event_points do
    collection do
      get "update_event_points"
    end
  end
  resources :tabling do
    collection do
      get 'generate'
      get 'options'
      get 'edit_tabling'
      get 'delete_slots'
      get 'manage'
      get 'convert'
      get 'commitments'

      # for testing progress bars
      get 'progress_update'
      get 'progress_dummmy'
      get 'progress_test'
    end
  end

  resources :resources do
  end
  #
  # handle drag-drop events in tabling index view only
  #
  resources :tabling_slot_members, only: [ :create, :destroy, :update ] do
    put :set_status_for, on: :member
  end
  

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
