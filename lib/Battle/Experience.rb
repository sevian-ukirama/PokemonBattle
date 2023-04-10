class BattleExperience

	def exp_calc(winner_pokemon, loser_pokemon)
		base_exp = loser_pokemon.base_experience
		level = loser_pokemon.level
		battle_participant_count = 2
		gained_exp = (base_exp*level)/7*1/battle_participant_count
	end

	def next_level_exp(pokemon)
		level = pokemon.level
		type = pokemon.type_1_id.to_sym
		growth = Rails.configuration.PokemonBattle[:GROWTH][type]
		next_level_requirement = level*(2*(level+1))/growth
	end

	def previous_level_exp(pokemon)
		level = pokemon.level-1
		type = pokemon.type_1_id.to_sym
		growth = Rails.configuration.PokemonBattle[:GROWTH][type]
		previous_level_requirement = level*(2*(level+1))/growth
	end

	def set_next_level_exp_requirement(pokemon)
		pokemon.next_level_experience = next_level_exp(pokemon)
	end

	def leveling_up?(pokemon)
		pokemon.current_experience >= pokemon.next_level_experience
	end

	def level_up(pokemon)
		pokemon.level = pokemon.level + 1
		gain_stats(pokemon)
		set_next_level_exp_requirement(pokemon)
	end

	def gain_stats(pokemon)
		pokemon.attack += (pokemon.attack.to_i/50.to_f).ceil
		pokemon.defense += (pokemon.defense.to_i/50.to_f).ceil
		pokemon.speed += (pokemon.speed.to_i/50.to_f).ceil
		pokemon.special_attack += (pokemon.special_attack.to_i/50.to_f).ceil
		pokemon.special_defense += (pokemon.special_defense.to_i/50.to_f).ceil
	end
end