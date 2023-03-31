class PokemonMove < ApplicationRecord
	belongs_to :pokemon
	belongs_to :move

	validates_uniqueness_of :move_id, scope: :pokemon_id
	validate :test

	private

	def test
		puts self.move_id, self.pokemon_id
	end
end
