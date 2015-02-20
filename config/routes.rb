Dockernotes::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :notes
  # root 'notes#index'
  # get "/authenticate", to: "sessions#sign_onto_google"
  get "/sign_out", to: "sessions#sign_out"
  get "/auth/google_oauth2/callback", to: "sessions#sign_onto_google"

  # get "/pull_google_events", to: "events#pull_google_events"
  root 'members#index'

  # get assassins route
  get "/assassins", to: "assassins#index"

  get '/test_auth', to: 'sessions#test_auth'
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
    end
    collection do
      get "pull_google_events"
      get "sync_google_events"
      get "list_google_events"
      get "list_events"
      get "delete_events"
      get 'create'
      get 'manage'
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
      post 'generate'
      get 'options'
      get 'edit_tabling'
      get 'delete_slots'
      get 'manage'
      get 'convert'

      # for testing progress bars
      get 'progress_update'
      get 'progress_dummmy'
      get 'progress_test'
    end
  end

  resources :commitments do
    collection do
      get 'update_commitments'
    end
  end
  #
  # handle drag-drop events in tabling index view only
  #
  resources :tabling_slot_members, only: [ :create, :destroy, :update ] do
    put :set_status_for, on: :member
  end


  #
  # scavenger resources
  #

  resources :scavenger_themes do 
    member do 
      get 'add_photo'
      post 'upload_photo'
      get 'generate_groups'
      get 'manage_groups'
    end
  end

  resources :scavenger_groups do 
    member do
      post 'upload_photo'
      get 'add_photo'
    end
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
