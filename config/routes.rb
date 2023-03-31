Rails.application.routes.draw do
  root 'battles#index'
  post 'battle/start', to: 'battles#create'  
  get 'battle/end/:id', to: 'battles#end', as: :battle_end
  get 'battle/finish/:id', to: 'battles#finish_battle', as: :battle_finish
  post 'battle/:id', to: 'battles#update'
  get 'pokemons/heal(/:id)', to: 'pokemons#heal', as: :pokemons_heal
  post 'pokemons/new', to: 'pokemons#create'  
  post 'pokemons/:id', to: 'pokemons#update'

  resources :pokemons
  resources :battles, path: :battle
end
