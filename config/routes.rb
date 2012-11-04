TodosSt2::Application.routes.draw do

  get "home/index"

  root :to => "home#index"

  opinio_model :controller => 'comments'

  resources :photos do
    opinio :controller => 'comments'
    resource :category
    member do
      get 'vote_up'
    end
  end

  resources :categories do
    resources :photos
  end

  devise_for :users, :controllers => {:sessions => 'sessions', :registrations => "registrations", :confirmations => "confirmations"}, :path_names => { :sign_in => 'login', :sign_out => 'logout'} do
    match 'login' => 'sessions#create', :via => [:post]
    match 'login' => 'sessions#new', :via => [:get]
    get 'logout' => 'sessions#destroy', :as => :destroy_user_session
  end

  devise_scope :user do
    match 'users/:id' => 'registrations#show'
    match 'users/:id/follow' => 'registrations#follow'
    match 'users/:id/unfollow' => 'registrations#unfollow'
    match 'users' => 'registrations#index'
  end

  resources :histories


  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      opinio_model :controller => 'comments'

      match 'photos/indexbbox(.:format)' => 'photos#indexbbox'
      resources :photos do
        opinio :controller => 'comments'
        resource :category
        member do
          get 'vote_up'
        end
      end

      resources :categories do
        resources :photos
      end

      devise_for :users, :controllers => {:sessions => 'Api::V1::sessions', :registrations => "Api::V1::registrations", :confirmations => "Api::V1::confirmations"}, :path_names => { :sign_in => 'api/v1/login', :sign_out => 'api/v1/logout'} do
        match 'login' => 'sessions#create', :via => [:post]
        match 'login' => 'sessions#new', :via => [:get]
        get 'logout' => 'sessions#destroy', :as => :destroy_user_session
      end

      devise_scope :user do
        match 'users/:id' => 'registrations#show'
        match 'users/:id/follow' => 'registrations#follow'
        match 'users/:id/unfollow' => 'registrations#unfollow'
        match 'users' => 'registrations#index'
      end

      resources :histories
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
