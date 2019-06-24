Rails.application.routes.draw do
  root 'index#home'
  get "game/new/:id/:forecast/:option/:offset", to: "game#new"
  get "game/weather/:id/:forecast/:option/:offset", to: "game#weather"
  get "screen/new/:id/:forecast/:option/:offset", to: "screen#new"
  get "screen/weather/:id/:forecast/:option/:offset", to: "screen#weather"
  match ':controller(/:action(/:id))', :via => [:get, :post]
end
