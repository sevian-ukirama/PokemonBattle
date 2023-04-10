class BattleHit
	require 'Pokemon/Type'
	
	# START HIT CALC
	def damage_calc(performer_pokemon, target_pokemon, move, critical_hit)
		level = performer_pokemon.level
		critical = critical_hit ? 2 : 1

		# First part of dmg Calc
		first_part_dmg = ((2*level*critical)/5)+2

		power = move.power.to_i
		
		# As per Bulbapedia, is Attack or Defense stat > 255, then stat / 4
		attack = performer_pokemon.attack > 255 ? performer_pokemon.attack.to_i/4 : performer_pokemon.attack
		defense = target_pokemon.defense > 255 ? target_pokemon.defense.to_i/4 : target_pokemon.defense

		# Uses lib/Pokemon/PokemonTypeChart
		type_chart = PokemonTypeChart.new
		type_1_effectiveness = type_chart.effectiveness(move.type_id, target_pokemon.type_1_id)
		type_2_effectiveness = target_pokemon.type_2_id.blank? ?
								1 : 
								type_chart.effectiveness(move.type_id, target_pokemon.type_2_id)

		same_type_bonus = (performer_pokemon.type_1_id == move.type_id) || (performer_pokemon.type_2_id == move.type_id) ?
						 1.5 :
						 1

		# Second part of dmg Calc
		second_part_dmg = ((first_part_dmg*power*attack/defense)/50)+2
		random = rand(0.85..1)

		total_dmg = second_part_dmg*same_type_bonus*type_1_effectiveness*type_2_effectiveness*random
		total_dmg.to_i
	end

	def critical_hit?
		rand(100) < 22
	end

	def reduce_pp(performer_move, usage_pp)
		unless performer_move.current_pp.zero?
			performer_move.current_pp = performer_move.current_pp.to_i - usage_pp.to_i
		end
	end

	def reduce_hp(pokemon, damage)
		pokemon.current_hp = pokemon.current_hp - damage
		pokemon.current_hp = pokemon.current_hp.positive? ? pokemon.current_hp : 0
	end

	def status_effect_hit?(move, pokemon)
		has_status_effect = move.status_effect_id != 'Normal'
		type_chart = PokemonTypeChart.new
		# If Type is resistant, doesn't affect
		pokemon_resistant = type_chart.status_resistant?(move.status_effect_id, pokemon.type_1_id) 
		status_effect_hit = rand(4) <= 2
		stacked_status = pokemon_already_afflicted_status?(pokemon, move.status_effect_id)

		has_status_effect && !stacked_status && !pokemon_resistant && status_effect_hit
	end

	def status_effect_hurt?(move)
		move.status_effect_id != 'Normal' && move.status_effect_id != 'Sleep'
	end

	def apply_status_damage(pokemon, status_dmg)
		reduce_hp(pokemon, status_dmg)
	end

	def apply_status_effect(pokemon, status_effect)
		pokemon.status_id = status_effect
	end

	def remove_pokemon_status_effect(pokemon)
		pokemon.status_id = 'Normal'
	end	

	def pokemon_already_afflicted_status?(pokemon, status_effect)
		pokemon.status_id == status_effect
	end
	# END HIT CALC 	
end