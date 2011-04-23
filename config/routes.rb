Twackr::Application.routes.draw do
  resources :clients do
    collection do
      get :report
    end
  end
  
  resources :services do
    collection do
      get :report
    end
  end
  
  resources :projects do
    collection do
      get :report
      get :entries
    end
  end
  
  resources :entries do
    member do
      put :terminate
    end
    collection do
      get :report
    end
  end
  
  resources :users
  
  resource :session
  match '/login',  :controller => 'sessions', :action => 'new', :as => :login
  match '/logout', :controller => 'sessions', :action => 'destroy', :as => :logout
  match '/settings',  :controller => 'users', :action => 'settings', :as => :settings

  match '/', :controller => :projects, :action => :entries, :as => :root
end
