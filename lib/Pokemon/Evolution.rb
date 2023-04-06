class PokemonEvolution
	def next_pokemon(pokemon)
		waiting_evolutions(pokemon).last.evolve_into
	end

	def waiting_evolutions(pokemon)
		current_evolution = pokemon.evolutions_as_pokemon[0]
		root_pokemon = Pokemon.find_by(id: current_evolution.root_pokemon)
		all_evolutions = root_pokemon.evolutions_as_root_pokemon
		waiting_evolutions = all_evolutions.where(at_level: ..pokemon.level, status: 'Waiting')
	end

	def evolve?(pokemon)
		!waiting_evolutions(pokemon).blank?
	end

	def evolve(pokemon)
		evolution = PokemonEvolution.new
		waiting_evolutions = evolution.waiting_evolutions(pokemon)
		next_pokemon = waiting_evolutions.last.evolve_into

		# Dups Pokemon
		pokemon.image_url = next_pokemon.image_url
		pokemon.name = next_pokemon.name
		pokemon.backstory = next_pokemon.backstory
		pokemon.current_hp = next_pokemon.maximum_hp
		pokemon.maximum_hp = next_pokemon.maximum_hp
		pokemon.speed = next_pokemon.speed
		pokemon.attack = next_pokemon.attack
		pokemon.defense = next_pokemon.defense
		pokemon.special_attack = next_pokemon.special_attack
		pokemon.special_defense = next_pokemon.special_defense
		pokemon.type_1_id = next_pokemon.type_1_id
		pokemon.type_2_id = next_pokemon.type_2_id

		accept_evolution(pokemon)

		if pokemon.save
			return true
		else
			return pokemon.errors.full_messages[0]
		end
	end

	def reject_evolution(pokemon)
		waiting_evolutions = waiting_evolutions(pokemon)
		waiting_evolutions.last.update(status: 'Rejected')
		# Set prev skipped evolutions to :Accepted
		accept_evolutions(pokemon)
	end

	def accept_evolution(pokemon)
		waiting_evolutions = waiting_evolutions(pokemon)
		waiting_evolutions.last.update(status: 'Accepted')
		# Set prev skipped evolutions to :Accepted
		accept_evolutions(pokemon)
	end

	def accept_evolutions(pokemon)
		status = 'Rejected'
		waiting_evolutions = waiting_evolutions(pokemon)
		waiting_evolutions.each do |waiting_evolution|
			status = 'Accepted' if waiting_evolution.Waiting?
			waiting_evolution.update(status: status)
		end
	end
end