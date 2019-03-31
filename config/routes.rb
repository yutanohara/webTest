Rails.application.routes.draw do
  # users controller
  post '/signup' => 'users#signup'
  get 'users/:id' => 'users#show'
  patch 'users/:id' => 'users#update'
  post 'close' => 'users#close'
end
