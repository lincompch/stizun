Stizun::Application.routes.draw do

  resources :addresses
  resources :orders
  resources :products
  resources :invoices
  resource :cart
  resource :account
  resources :user_sessions
  
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  
  
  resources :categories do
    resources :products
  end

  resource :account
  resources :users do
    resources :carts
    resources :orders
    resources :invoices
    resources :accounts
    resources :addresses
  end

  resources :shipping_rates do
    resources :shipping_costs
  end
  
  match '/admin' => 'admin/dashboard#index', :as => :admin
  
  # Namespace admin
  namespace :admin do
    
    resources :products do
      resources :components
      resources :product_pictures
      collection do
        get 'new_from_supply_item'
      end
      member do
        get 'switch_to_supply_item'
      end
    end
   
    resources :product_pictures 
    resources :tax_classes
    resources :orders
    resources :countries
    
    resources :invoices do
      collection do
        post :create_from_order
        post :resend_invoice
      end
    end
    
    resources :shipping_costs
    resources :shipping_rates
    resources :histories
    resources :payment_methods
    resources :configuration_items
    
    resources :users do
      resources :accounts
      resources :addresses
    end
    
    resources :journal_entries
    resources :account_transactions
    
    resources :accounts do
      resources :account_transactions
      resources :journal_entries
    end
    
    resources :categories do 
      resources :products
    end
    
    resources :suppliers do
      resources :supply_items
      resources :shipping_rates
    end
    
  end
  # End of namespace admin

  match 'invoice/:uuid' => 'invoices#uuid'
  match '/' => 'page#index'
  match '/:controller(/:action(/:id))'
  
  root :to => "page#index"
end
