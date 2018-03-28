Rails.application.routes.draw do
  root 'index#home'
  get "game/new/:id/:forecast", to: "game#new"
  match ':controller(/:action(/:id))', :via => [:get, :post]
end
