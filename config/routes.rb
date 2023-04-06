Rails.application.routes.draw do
  root 'battles#index'

  get 'battle/end/:id', to: 'battles#end', as: :battle_end
  get 'battle/finish/:id', to: 'battles#finish_battle', as: :battle_finish
  post 'battle/start', to: 'battles#create'  
  post 'battle/:id', to: 'battles#update'

  get 'pokedex/heal(/:id)', to: 'pokemons#heal', as: :pokedex_heal
  get 'pokedex/:id/evolution', to: 'pokemons#evolution', as: :pokedex_evolution
  post 'pokedex/:id/learn', to: 'pokemons#learn_moves', as: :learn_move
  post 'pokedex/:id/evolution', to: 'pokemons#evolve', as: :pokedex_evolve

  resources :pokemons, path: :pokedex
  resources :battles, path: :battle
end

