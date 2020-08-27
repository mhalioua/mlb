Rails.application.routes.draw do
  root 'index#home'
  get "game/new/:id/:forecast/:option(/:offset)", to: "game#new"
  get "game/weather/:id/:forecast/:option(/:offset)", to: "game#weather"
  match ':controller(/:action(/:id))', :via => [:get, :post]
end
