class Pokemon < ApplicationRecord
	has_many :battles_as_pokemon_1, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_1_id', primary_key: 'id'
	has_many :battles_as_pokemon_2, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_2_id', primary_key: 'id'
	has_many :pokemon_moves
	has_many :moves, through: :pokemon_moves
	accepts_nested_attributes_for :pokemon_moves

	enum type_id: ['Normal','Fire','Water','Grass','Electric','Ice','Fighting','Poison','Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon']
	enum status_id: ['Normal', 'Paralysis', 'Poison', 'Sleep', 'Frozen', 'Burn','Faint'], _prefix: :pokemon
end
