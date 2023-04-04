class BattlesController < ApplicationController
	require 'Pokemon/TypeCalculation'

	before_action :check_battle_status,:check_battle_winner,:is_battle_exist?, only: [:show]

	def index
		@battles = Battle.order(created_at: :asc)
	end

	def new
		@pokemons = Pokemon.order(name: :asc).all
		@pokemon_moves = PokemonMove.order(pokemon_id: :asc).all
		@moves = Move.order(name: :asc).all
	end

	def create
		battle = Battle.new
		pokemon_1 = Pokemon.find(params[:battle][:pokemon_1_id])
		pokemon_2 = Pokemon.find(params[:battle][:pokemon_2_id])

		if pokemon_1.speed >= pokemon_2.speed
			battle.pokemon_1_id = params[:battle][:pokemon_1_id]
			battle.pokemon_2_id = params[:battle][:pokemon_2_id]
			flash[:warning] = "#{pokemon_1.name} attacks first!"
		else
			battle.pokemon_1_id = params[:battle][:pokemon_2_id]
			battle.pokemon_2_id = params[:battle][:pokemon_1_id]
			flash[:warning] = "#{pokemon_2.name} attacks first!"
		end

		battle.status_id = 0
		if battle.save
			flash[:success] = "Battle starting now"
			redirect_to battle_path(battle)
		else
			flash[:danger] = "#{battle.errors.full_messages[0]}."
			flash[:warning] = "Battle Cannot Start"
			redirect_to new_battle_path
		end
	end

	def show
		@battle = Battle.find(params[:id])
		if @battle.status_id == 'ongoing'
			@pokemon_1 = @battle.pokemon_1
			@pokemon_2 = @battle.pokemon_2
			@pokemon_1_moves = @pokemon_1.pokemon_moves.order(row_order: :asc).joins(:move).order(name: :asc).all
			@pokemon_2_moves = @pokemon_2.pokemon_moves.order(row_order: :asc).joins(:move).order(name: :asc).all

			render 'ongoing'
		else
			redirect_to battle_end_path
		end
	end

	def update
		battle = Battle.find(params[:id])
		submitted_move_pokemon_id = params[:battle][:submitted_move_pokemon_id]
		submitted_move_id = params[:battle][:submitted_move_id]
		submitted_move_row_order = params[:battle][:submitted_move_row_order]

		performer_pokemon = battle.turn_number.odd? ? battle.pokemon_1 : battle.pokemon_2
		target_pokemon = battle.turn_number.odd? ? battle.pokemon_2 : battle.pokemon_1

		move = performer_pokemon.moves.find_by(id: submitted_move_id)

		# Prevent Pokemon hijacking other's move
		if submitted_move_pokemon_id.to_i != performer_pokemon.id.to_i
			flash[:danger] = "Not #{target_pokemon.name}'s turn!"
			return redirect_to battle_path(params[:id])
		end

		# If random > accuracy, not hit
		# i.e If accuracy = 70, means move has 70% of hitting enemy
		hit = rand(100) < move.accuracy if !move.blank?

		if hit
			perform_hit(performer_pokemon, target_pokemon, submitted_move_id, submitted_move_row_order)
		else
			flash[:warning] = "#{performer_pokemon.name} attack Missed!"
		end

		next_turn_counter = 1 
		if target_pokemon.status_id == 'Sleep' || target_pokemon.status_id == 'Frozen'
			next_turn_counter += 1 
			flash[:secondary] = "#{target_pokemon.name} is now affected with #{target_pokemon.status_id}. Turn has been Skipped!"
		end

		add_turn_number(battle, next_turn_counter)
		unless battle.save
			flash[:danger] = battle.errors.full_messages[0]
		end

		redirect_to battle_path(params[:id])	
	end

	def add_turn_number(battle, next_turn_counter)
		battle.turn_number = battle.turn_number+next_turn_counter
	end


	# START HIT CALC
	def perform_hit(performer_pokemon, target_pokemon, submitted_move_id, submitted_move_row_order)
		performer_move = performer_pokemon.pokemon_moves.find_by(move_id: submitted_move_id, row_order: submitted_move_row_order)
		move = performer_pokemon.moves.find_by(id: submitted_move_id)
		# Damage calculation
		damage = damage_calc(performer_pokemon, target_pokemon, move)

		reduce_pp(performer_move, move.usage_pp)
		reduce_hp(target_pokemon, damage)

		# If User is spamming same move status, status doesn't stack
		# If Type is resistant, doesn't affect
		type_chart = PokemonTypeChart.new
		target_pokemon_resistant = type_chart.status_resistant?(move.status_effect_id, target_pokemon.type_1_id) 

		status_effect_hit = rand(100) < 33

		if target_pokemon.status_id != move.status_effect_id && !target_pokemon_resistant && status_effect_hit
			add_status_effect_to_pokemon(target_pokemon, move.status_effect_id)
			check_pokemon_status(target_pokemon)
		else
			flash[:warning] = "Oh no, #{target_pokemon.name} resisted #{move.status_effect_id }"
			remove_pokemon_status_effect(target_pokemon)
		end

		# Saves Perfomer & Target & Move Updation
		if performer_pokemon.save && target_pokemon.save && performer_move.save
			flash[:success] = "#{target_pokemon.name} hit for #{damage} dmg!"
		else 
			flash[:danger] = "Moves failed to perform. #{performer_pokemon.errors.full_messages[0]} and #{target_pokemon.errors.full_messages[0]}"
		end
	end

	def damage_calc(performer_pokemon, target_pokemon, move)
		level = performer_pokemon.level
		critical = rand(100) < 22 ? 2 : 1

		# If critical, flash message
		if critical == 2
			flash[:primary] = "Critical Hit!"
		end

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

	def reduce_pp(performer_move, usage_pp)
		unless performer_move.current_pp.zero?
			performer_move.current_pp = performer_move.current_pp.to_i - usage_pp.to_i
		end
	end

	def reduce_hp(target_pokemon, damage)
		target_pokemon.current_hp = target_pokemon.current_hp - damage
		target_pokemon.current_hp = target_pokemon.current_hp.positive? ? target_pokemon.current_hp : 0
	end

	def check_pokemon_status(pokemon)
		if pokemon.status_id != 'Normal' && pokemon.status_id != 'Sleep'
			random_status_dmg = rand(1..10)
			reduce_hp(pokemon, random_status_dmg)
			flash[:secondary] = "#{pokemon.name} is now affected with #{pokemon.status_id} and damaged for #{random_status_dmg} dmg!"
		end
	end

	def add_status_effect_to_pokemon(target_pokemon, status_effect)
		target_pokemon.status_id = status_effect
	end

	def remove_pokemon_status_effect(pokemon)
		pokemon.status_id = 'Normal'
	end	
	# END HIT CALC 


	def end
		@battle = Battle.find(params[:id])
		if @battle.status_id == 'finished'
			@winner_pokemon = @battle.winner_pokemon

			# Leveling Up Flag
			@level_up = @winner_pokemon.is_leveling_up
			if @level_up
				@waiting_moves = @winner_pokemon
									.default_moves
									.where(status: :Waiting, at_level: ...@winner_pokemon.level)
			end
		else
			redirect_to battle_path(@battle)
		end
	end

	def finish_battle
		battle = Battle.find(params[:id])
		# Only end battle if turn is more than 2
		if battle.turn_number > 2
			set_battle_winner(battle)
			flash[:success] = "Battle #{battle.id} is now Finished. #{battle.winner_pokemon.name} is the Winner!"
			redirect_to root_url
		else
			flash[:danger] = "Pokemon #{battle.turn_number%2+1} haven't made a move yet!"
			redirect_to battle_path(battle)
		end
	end

	def set_battle_winner(battle)
		# Get hp percentage of each pokemon
		pokemon_1_hp_percentage = 100*battle.pokemon_1.current_hp/battle.pokemon_1.maximum_hp
		pokemon_2_hp_percentage = 100*battle.pokemon_2.current_hp/battle.pokemon_2.maximum_hp


		# Ones with higher hp percentage wins 
		battle.winner_pokemon_id = pokemon_1_hp_percentage > pokemon_2_hp_percentage ? 
									battle.pokemon_1.id :
									battle.pokemon_2.id	

		battle.loser_pokemon_id = pokemon_1_hp_percentage > pokemon_2_hp_percentage ? 
									battle.pokemon_2.id	:
									battle.pokemon_1.id
		battle.status_id = 'finished'

		if battle.save
			gain_exp(battle.winner_pokemon, battle.loser_pokemon)
		else
			flash[:danger] = battle.errors.full_messages[0]
		end
	end


	# START LEVELING

	def gain_exp(winner_pokemon, loser_pokemon)
		base_exp = loser_pokemon.base_experience
		level = loser_pokemon.level
		battle_participant_count = 2
		gained_exp = (base_exp*level)/7*1/battle_participant_count

		# Set first level experience requirement
		if winner_pokemon.next_level_experience.blank?
			set_next_level_exp_requirement(winner_pokemon)
		end

		winner_pokemon.current_experience = winner_pokemon.current_experience+gained_exp
		winner_pokemon.is_leveling_up = false
		# Check is leveling Up and for View
		while leveling_up?(winner_pokemon)
			level_up(winner_pokemon)
			winner_pokemon.is_leveling_up = true
		end

		unless winner_pokemon.save
			flash[:danger] = winner_pokemon.errors.full_messages[0]
		end
	end

	def next_level_exp(pokemon)
		level = pokemon.level
		type = pokemon.type_1_id.to_sym
		growth = Rails.configuration.PokemonBattle[:GROWTH][type]
		next_level_requirement = level*(2*(level+1))/growth
	end

	def set_next_level_exp_requirement(pokemon)
		pokemon.next_level_experience = next_level_exp(pokemon)
	end

	def leveling_up?(pokemon)
		pokemon.current_experience >= pokemon.next_level_experience
	end

	def level_up(pokemon)
		pokemon.level = pokemon.level + 1
		set_next_level_exp_requirement(pokemon)
	end

	# END LEVELING


	def destroy
		battle = Battle.find(params[:id])
		if battle.destroy
			flash[:warning] = 'Battle has been deleted!'
		else
			flash[:danger] = battle.errors.full_messages[0]
		end

		redirect_to root_url
	end

	private

	def is_battle_exist?
		battle = Battle.find_by(id: params[:id])
		if battle.blank?
			flash[:danger] = "Battle Not Found"
			redirect_to root_url
		end
	end

	def check_battle_status
		battle = Battle.find(params[:id])
		if battle.status_id == 'finished'
			redirect_to battle_end_path(battle)
		end
	end

	def check_battle_winner
		battle = Battle.find(params[:id])
		pokemon_1 = battle.pokemon_1
		pokemon_2 = battle.pokemon_2

		if self.zero_hp?(pokemon_1) || self.zero_available_moves?(pokemon_1)
			set_battle_winner(battle)
			flash[:dark] = "#{pokemon_1.name} ran out of HP!"
			flash[:light] = "#{pokemon_1.name} ran out of Moves!"
		elsif self.zero_hp?(pokemon_2) || self.zero_available_moves?(pokemon_2)
			set_battle_winner(battle)
			flash[:dark] = "#{pokemon_2.name} ran out of HP!"
			flash[:light] = "#{pokemon_2.name} ran out of Moves!"
		end
	end

	def zero_hp?(pokemon)
		pokemon.current_hp.zero?
	end

	def zero_available_moves?(pokemon)
		zero_available_moves = true
		pokemon.pokemon_moves.each do |move|
			zero_available_moves = !move.current_pp.zero? ? false : zero_available_moves
		end
		zero_available_moves
	end

end
