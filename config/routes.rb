Rails.application.routes.draw do
  root 'battles#index'
  post 'battle/start', to: 'battles#create'  
  get 'battle/end/:id', to: 'battles#end', as: :battle_end
  post 'battle/:id', to: 'battles#update'
  get 'pokemons/heal(/:id)', to: 'pokemons#heal', as: :pokemons_heal
  post 'pokemons/new', to: 'pokemons#create'  
  # get 'battle/:id', to: 'battles#ongoing'  
  resources :pokemons
  resources :battles, path: :battle
end
