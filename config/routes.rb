ActionController::Routing::Routes.draw do |map|
  map.resources :clients, :collection => {:report => :get}

  map.resources :services, :collection => {:report => :get}

  map.resources :projects, :collection => {:report => :get, :entries => :get}
  
  map.resources :entries, :member => {:terminate => :put}, :collection => {:report => :get} 
  map.resources :users, :collection => {:forgot_password => :any}
  
  map.resource :session
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.root :controller => :projects, :action => :entries
end
