class PokemonMove < ApplicationRecord
	belongs_to :pokemon
	belongs_to :move

	validates_uniqueness_of :move_id, scope: :pokemon_id

end
