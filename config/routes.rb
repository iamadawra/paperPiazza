Paperpiazza::Application.routes.draw do

  get "profile/feed"

  root to:'activity#feed'

  resources :courses, :path => "papers"

  resources :categories, :except => [:index, :show]
  resources :forums, :except => :index do
    resources :topics, :shallow => true, :except => :index do
      resources :posts, :shallow => true, :except => [:index, :show]
    end
  end

  resources :assignments do
    resources :questions do
      # TODO: Fix me! This nesting exists solely for this route.
      # We need questions to depend on Courses not Assignments.
      resources :submissions, :controller => 'question_submissions', :except => [:destroy]
    end
  end

  resources :courses do
    resources :comments, :only => [:create, :destroy]
    resources :memberships, :controller => :course_memberships, :only => [:create, :destroy]

    resources :lectures
    resources :assignments
    resources :questions do
      resources :rubric_items
      resources :submissions, :controller => 'question_submissions', :except => [:destroy]
    end
    match 'search/questions/(:key)' => 'questions#search', :as => 'question_search'
  end

  # Want this at some point..
  resources :users

  resources :tags

  resources :courses do
    post :rate, :on => :member
  end

  resource :account, except: [:destroy]
  match '/register', to: 'accounts#new'
  match '/account/:id', to: 'accounts#profile'
  
  match 'ability_switch', to: 'courses#switch'
  resources :password_resets

  resource :user_session, only: [:new, :create, :destroy]
  get   '/login',  to: 'user_sessions#new'
  post  '/login',  to: 'user_sessions#create', :as => :login_post
  match '/logout', to: 'user_sessions#destroy'


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
  # match ':controller(/:action(/:id))(.:format)'
end
