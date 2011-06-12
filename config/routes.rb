Stizun::Application.routes.draw do

  resources :addresses
  resources :orders
  resources :products do
    member do
      post :subscribe
    end
  end
  resources :invoices
  resource :cart
  devise_for :users
  #match 'login' => 'user_sessions#new', :as => :login
  #match 'logout' => 'user_sessions#destroy', :as => :logout
  
  match 'products/unsubscribe/:remove_hash' => 'notification#destroy', :as => :unsubscribe_product
  match 'notifications' => 'notification#index', :as => :notifications
  
  resources :categories do
    resources :products
  end

  resources :users do
    resources :carts
    resources :orders
    resources :invoices
    resources :addresses
  end

  resources :shipping_rates do
    resources :shipping_costs
  end
  
  match '/admin' => 'admin/dashboard#index', :as => :admin
  match '/users/me' => "users#show", :as => :show_current_profile
  # Namespace admin
  namespace :admin do
    
    resources :products do
      resources :components
      resources :product_pictures
      collection do
        get 'having_unavailable_supply_item'
        get 'new_from_supply_item'
      end
      member do
        get 'switch_to_supply_item'
      end
    end
   
    resources :product_pictures 
    resources :tax_classes
    resources :orders do
      resources :order_lines
    end
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
      resources :addresses
    end
    
    resources :categories do 
      resources :products
    end
    
    resources :suppliers do
      resources :supply_items
      resources :shipping_rates
      resources :products
      resources :categories do
        resources :products
      end
    end
    
  end
  # End of namespace admin

  match 'invoice/:uuid' => 'invoices#uuid'
  match '/' => 'page#index'
  match '/:controller(/:action(/:id))'
  
  root :to => "page#index"
end
