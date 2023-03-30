class BattlesController < ApplicationController
	require 'Pokemon/TypeCalculation'

	before_action :check_battle_status, only: [:show]

	def index
		@battles = Battle.order(created_at: :asc)
	end

	def new
		@pokemons = Pokemon.all
		@moves = @pokemons.joins(:pokemon_moves)
	end

	def create
		battle = Battle.new
		battle.pokemon_1_id = params[:battle][:pokemon_1_id]
		battle.pokemon_2_id = params[:battle][:pokemon_2_id]
		battle.status_id = 0
		if battle.save
			flash[:success] = "Battle starting now"
			redirect_to battle_path(battle)
		else
			flash[:danger] = "#{battle.errors.full_messages[0]}."
			redirect_to new_battle_path
		end
	end

	def show
		@battle = Battle.find(params[:id])
		if @battle.status_id == 'ongoing'
			@pokemon_1 = Pokemon.find(@battle.pokemon_1_id)
			@pokemon_2 = Pokemon.find(@battle.pokemon_2_id)
			@pokemon_1_moves = @pokemon_1.pokemon_moves.joins(:move).all
			@pokemon_2_moves = @pokemon_2.pokemon_moves.joins(:move).all

			render 'ongoing'
		else
			redirect_to battle_end_path
		end
	end

	def update
		battle = Battle.find(params[:id])
		submitted_move_id = params[:battle][:submitted_move_id]
		submitted_usage_pp = params[:battle][:submitted_move_pp]
		performer_pokemon = battle.turn_number.odd? ? battle.pokemon_1 : battle.pokemon_2
		target_pokemon = battle.turn_number.odd? ? battle.pokemon_2 : battle.pokemon_1

		move = performer_pokemon.moves.find_by(id: submitted_move_id)
		# If random > accuracy, not hit
		# i.e If accuracy = 70, means move has 70% of hitting enemy
		hit = rand(100) < move.accuracy

		if hit
			perform_hit(performer_pokemon, target_pokemon, submitted_move_id)
			check_battle_winner(battle)
		else
			flash[:warning] = "Attack Missed"
		end

		next_turn_counter = 1 
		if target_pokemon.status_id == 'Sleep' || target_pokemon.status_id == 'Frozen'
			next_turn_counter += 1 
			flash[:secondary] = "#{target_pokemon.name} is now affected with #{target_pokemon.status_id}. Turn has been Skipped!"
		end

		add_turn_number(battle, next_turn_counter)
		unless battle.save
			flash[:danger] = 'Failed to change Turn'
		end

		redirect_to battle_path(params[:id])	
	end

	def add_turn_number(battle, next_turn_counter)
		battle.turn_number = battle.turn_number+next_turn_counter
	end

	def perform_hit(performer_pokemon, target_pokemon, submitted_move_id)
		performer_move = performer_pokemon.pokemon_moves.find_by(move_id: submitted_move_id)
		move = performer_pokemon.moves.find_by(id: submitted_move_id)

		# Damage calculation
		damage = damage_calc(performer_pokemon, target_pokemon, move)

		reduce_pp(performer_move, move.usage_pp)
		reduce_hp(target_pokemon, damage)

		# If User is spamming same move status, status doesn't stack
		# If Type is resistant, doesn't affect
		type_chart = PokemonTypeChart.new
		target_pokemon_resistant = type_chart.status_resistant?(move.status_effect_id, target_pokemon.type_1_id) 

		if target_pokemon.status_id != move.status_effect_id && !target_pokemon_resistant
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
		level = 1
		critical = rand(100) < 22 ? 2 : 1

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

		same_type_bonus = performer_pokemon.status_id == move.status_effect_id ? 1.5 : 1

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

	def check_battle_winner(battle)
		pokemon_1 = battle.pokemon_1
		pokemon_2 = battle.pokemon_2

		if pokemon_1.current_hp.zero?
			battle.winner_pokemon_id = battle.pokemon_2_id
			battle.status_id = 'finished'
			if battle.save
				flash[:success] = 'Battle is over!'
			else
				flash[:danger] = battle.errors.full_messages[0]
			end
		elsif pokemon_2.current_hp.zero?
			battle.winner_pokemon_id = battle.pokemon_1_id
			battle.status_id = 'finished'
			if battle.save
				flash[:success] = 'Battle is over!'
			else
				flash[:danger] = battle.errors.full_messages[0]
			end
		end
	end

	def end
		@battle = Battle.find(params[:id])
		if @battle.status_id = 'finished'
			@winner_pokemon = Pokemon.find(@battle.winner_pokemon_id)
		else
			redirect_to battle_path(@battle)
		end
	end

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

	def check_battle_status
		battle = Battle.find(params[:id])
		if battle.status_id == 'finished'
			redirect_to battle_end_path(battle)
		end
	end

end
