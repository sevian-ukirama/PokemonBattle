Rails.application.routes.draw do
  root 'battles#index'

  get 'battle/end/:id', to: 'battles#end', as: :battle_end
  get 'battle/finish/:id', to: 'battles#finish_battle', as: :battle_finish
  post 'battle/start', to: 'battles#create'  
  post 'battle/:id', to: 'battles#update'

  get '/pokedex', to: 'pokemons#pokedex', as: :pokedex
  get 'pokemons/heal(/:id)', to: 'pokemons#heal', as: :pokemons_heal
  post 'pokemons/new', to: 'pokemons#create'  
  post 'pokedex/:id', to: 'pokemons#update'
  post 'pokemons/:id/learn', to: 'pokemons#learn_moves', as: :learn_move

  resources :pokemons, path: :pokedex
  resources :battles, path: :battle
end

