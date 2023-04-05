class Move < ApplicationRecord
	has_many :pokemon_moves
	has_many :pokemons, through: :pokemon_moves

	has_many :default_moves
	has_many :pokemons, through: :default_moves

	enum type_id: ['Normal','Fire','Water','Grass','Electric','Ice','Fighting','Poison','Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon'], _prefix: :type
	enum status_effect_id: ['Normal', 'Paralysis', 'Poison', 'Sleep', 'Frozen', 'Burn']
end
