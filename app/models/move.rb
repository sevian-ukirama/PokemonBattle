class Move < ApplicationRecord
	has_many :pokemon_moves
	has_many :pokemons, through: :pokemon_moves

	enum status_effect_id: ['Normal', 'Paralysis', 'Poison', 'Sleep', 'Frozen', 'Burn']
end
