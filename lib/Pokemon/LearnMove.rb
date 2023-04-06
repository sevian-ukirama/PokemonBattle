class PokemonLearnMove
	def reject_waiting(pokemon)
		default_moves = pokemon.default_moves.where(status: 'Waiting')
		default_moves.each do |default_move|
			default_move.update(status: 'Rejected')
		end
	end
end