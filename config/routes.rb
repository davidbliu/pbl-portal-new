Dockernotes::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :notes
  # root 'notes#index'
  get "/authenticate", to: "sessions#sign_onto_google"
  get "/sign_out", to: "sessions#sign_out"
  get "/auth/google_oauth2/callback", to: "sessions#sign_onto_google"

  # get "/pull_google_events", to: "events#pull_google_events"
  root 'members#index'

  # get assassins route
  get "/assassins", to: "assassins#index"

  get '/test_auth', to: 'sessions#test_auth'
  resources :members do
    collection do
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
      get 'rankings'
      get 'mark_attendance'
      post 'update_attendance'
      get 'apprentice'
      get 'coocurrence'
    end

  end

  resources :events do
    collection do
      get "pull_google_events"
      get "sync_google_events"
      get "list_google_events"
    end
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
