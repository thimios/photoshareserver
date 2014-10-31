PhotoShareServer::Application.routes.draw do

  resources :quotes

  get "home/launchrock"
  get "home/facebook"

  match 'home' => "home#home", :as => :home
  match 'about' => 'home#about', :as => :about
  match 'terms' => 'home#terms', :as => :terms
  match 'press' => "home#press", :as => :press
  match 'contact' => "home#contact", :as => :contact
  match 'privacy' => "home#privacy", :as => :privacy

  match 'home/photo/:id' => 'home#photo_details', :as => :photo_details
  match 'home/photos_paging' => 'home#photos_paging', :as => :photos_paging
  match 'home/:id' => 'home#home_photo_detail', :as => :home_photo_detail

  # admin routes
  match 'admin' => "admin#home", :as => :admin

  root :to => "home#home"
  #root :to => "home#home"  # production home page

  opinio_model :controller => 'comments'


  get 'photos/destroy_all_reported'
  get 'photos/ban_all_reported'

  resources :photos do
    opinio :controller => 'comments'
    resource :category


    member do
      post 'toggle_ban'
      post 'refuse_ban'

    end
  end



  resources :categories do
    resources :photos
  end

  devise_for :users, :controllers => {:sessions => 'sessions', :registrations => "registrations", :confirmations => "confirmations", :passwords => "passwords"}, :path_names => { :sign_in => 'login', :sign_out => 'logout'}

  devise_scope :user do
    match 'login' => 'sessions#create', :via => [:post]
    match 'login' => 'sessions#new', :via => [:get]
    get 'logout' => 'sessions#destroy', :as => :destroy_user_session
    match 'users/messages' => 'registrations#messages'
    get 'users/search' => "users#search", :as => :user_search
    match 'users/:id/follow' => 'registrations#follow'
    match 'users/:id/unfollow' => 'registrations#unfollow'
  end

  get 'users/csv' => 'users#csv', :as => :users_csv
  resources :users, :except => [ :destroy, :create, :new ] do
    post :generate_new_password_email
  end

  resources :histories

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      opinio_model :controller => 'comments'

      #resources :quotes
      match 'quote(.:format)' => 'quotes#show'

      match 'photos/indexbbox(.:format)' => 'photos#indexbbox'
      resources :photos do
        opinio :controller => 'comments'
        resource :category
        member do
          get 'vote_up'
          get 'report'
        end
      end

      resources :categories do
        resources :photos
      end

      devise_for :users, :controllers => {:sessions => 'api/v1/sessions', :registrations => "api/v1/registrations", :confirmations => "api/v1/confirmations"}, :path_names => { :sign_in => 'login', :sign_out => 'logout'}

      devise_scope :user do
        match 'login' => 'sessions#create', :via => [:post]
        match 'login' => 'sessions#new', :via => [:get]
        get 'logout' => 'sessions#destroy', :as => :destroy_user_session
        match 'users/suggested' => 'registrations#suggested_followable_users'
        match 'users/:id' => 'registrations#show'
        match 'users/:id/follow' => 'registrations#follow'
        match 'users/:id/unfollow' => 'registrations#unfollow'
        match 'users' => 'registrations#index', :via => [:get]
      end

      resources :histories


      match 'named_locations/:location_google_id/follow' => 'named_locations#follow'
      match 'named_locations/:location_google_id/unfollow' => 'named_locations#unfollow'
      match 'named_locations/suggested' => 'named_locations#suggested_followable_locations'
      match 'named_locations/:id' => 'named_locations#show'
      get 'named_locations' => 'named_locations#index'
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.
  

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(.:format)(/:id))'
end
