ActionController::Routing::Routes.draw do |map|


  # The priority is based  order of creation: first created -> highest priority.

  map.resources :addresses
  map.resources :orders
  map.resources :products
  map.resources :invoices

  # A kind of alias so that /cart works like /carts
  # It sounds more intuitive at the moment, because right now
  # the system does not support multiple carts per user.
  map.resource :cart, :controller => "carts"

  map.resource :account, :controller => "users"  
  map.resources :user_sessions
  map.login 'login', :controller => 'user_sessions', :action => 'new'  
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'  
  
  
  map.resources :categories do |category|
    category.resources :products
  end
  
  # A user has an account and can (when logged in) view their
  # own invoices. Perhaps remove direct access to the 
  # invoice and order resources once this is finished?
  map.resource :account, :controller => "users"
  map.resources :users do |user|
    user.resources :carts
    user.resources :orders
    user.resources :invoices
    user.resources :accounts
    user.resources :addresses
  end

  map.resources :shipping_rates do |sr|
    sr.resources :shipping_costs
  end
  
  # Admin backend
  map.admin '/admin', :controller => 'admin/dashboard'
  map.namespace :admin do |admin|
    admin.resources :products, :collection => { :create_from_supply_item => :get,
                                                #:components => :get,
                                                :add_component => :post } do |pr|
      pr.resources :components
        
    end
    
    admin.resources :tax_classes
    admin.resources :orders
    admin.resources :countries
    admin.resources :invoices, :collection => { :create_from_order => :post }
    admin.resources :shipping_costs
    admin.resources :shipping_rates
    admin.resources :histories
    admin.resources :payment_methods
    admin.resources :users do |us|
      us.resources :accounts
    end
    admin.resources :journal_entries
    admin.resources :account_transactions
    admin.resources :accounts do |acc|
      acc.resources :account_transactions
      acc.resources :journal_entries
    end
    admin.resources :categories do |cat|
      cat.resources :products
    end
    admin.resources :suppliers do |sup|
      sup.resources :supply_items
      sup.resources :shipping_rates
    end
  end


  map.connect 'invoice/:uuid', :controller => 'invoices', :action => 'uuid'
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "page"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
