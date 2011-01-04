ActionController::Routing::Routes.draw do |map|
   resources :sessions
   match '/login' => "sessions#new"
   match '/logout' => "sessions#destroy"
   match '/oauth_callback' => "sessions#oauth_callback"

#  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
#  map.resource :session
end
