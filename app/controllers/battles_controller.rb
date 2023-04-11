class BattlesController < ApplicationController
	require 'Battle/Experience'
	require 'Battle/Hit'
	require 'Pokemon/Evolution'

	before_action :check_battle_status,:check_battle_winner,:is_battle_exist?, only: [:show]

	def index
		@battles = Battle.paginate(page: params[:page], per_page: 15).order(created_at: :asc)
	end

	def new
		@pokemons = Pokemon.order(name: :asc).all
		@pokemon_moves = PokemonMove.all
		@moves = Move.all
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
		if performer_pokemons_move?(submitted_move_pokemon_id, performer_pokemon)
			flash[:danger] = "Not #{target_pokemon.name}'s turn!"
			return redirect_to battle_path(params[:id])
		end

		perform_hit(performer_pokemon, target_pokemon, submitted_move_id, submitted_move_row_order)

		next_turn_counter = 1 
		if pokemon_immobilized?(target_pokemon)
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

	def performer_pokemons_move?(move_pokemon_id, pokemon)
		move_pokemon_id.to_i != pokemon.id.to_i
	end

	def pokemon_immobilized?(pokemon)
		pokemon.status_id == 'Sleep' || pokemon.status_id == 'Frozen'
	end

	# Hit
	def perform_hit(performer_pokemon, target_pokemon, submitted_move_id, submitted_move_row_order)
		battle_hit = BattleHit.new
		performer_move = performer_pokemon.pokemon_moves.find_by(move_id: submitted_move_id, row_order: submitted_move_row_order)
		move = performer_pokemon.moves.find_by(id: submitted_move_id)

		# If random > accuracy, not hit
		# i.e If accuracy = 70, means move has 70% of hitting enemy
		hit = rand(10) < move.accuracy.to_i/10 if !move.blank?

		if hit
			critical = battle_hit.critical_hit?
			damage = battle_hit.damage_calc(performer_pokemon, target_pokemon, move, critical)
			battle_hit.reduce_hp(target_pokemon, damage)

			if critical
				flash[:primary] = "Critical Hit!"
			end
			perform_status_effect(performer_pokemon, target_pokemon, move)
			flash[:success] = "#{target_pokemon.name} hit for #{damage} dmg!"
		else
			flash[:warning] = "#{performer_pokemon.name} attack Missed!"
		end

		battle_hit.reduce_pp(performer_move, move.usage_pp)

		# Saves Perfomer & Target & Move Updation
		unless performer_pokemon.save && target_pokemon.save && performer_move.save
			flash[:danger] = "Moves failed to perform. #{performer_pokemon.errors.full_messages[0]} and #{target_pokemon.errors.full_messages[0]}"
		end
	end

	def perform_status_effect(performer_pokemon, target_pokemon, move)
		battle_hit = BattleHit.new
		if battle_hit.status_effect_hit?(move, target_pokemon)
			battle_hit.apply_status_effect(target_pokemon, move.status_effect_id)
			if battle_hit.status_effect_hurt?(move)
				status_dmg = rand(1..10)
				battle_hit.apply_status_damage(target_pokemon, status_dmg)
			end
			flash[:secondary] = "#{target_pokemon.name} is now affected with #{target_pokemon.status_id} and damaged for #{status_dmg} dmg!"
		else
			battle_hit.remove_pokemon_status_effect(target_pokemon)
			flash[:warning] = "Oh no, #{target_pokemon.name} resisted #{move.status_effect_id }"
		end
	end
	# 

	def end
		battle_exp = BattleExperience.new
		@battle = Battle.find(params[:id])

		if @battle.status_id != 'finished'
			return redirect_to battle_path(@battle)
		end

		@winner_pokemon = @battle.winner_pokemon
		@learned_moves = @winner_pokemon.pokemon_moves

		# Leveling Up Flag
		@level_up = @winner_pokemon.is_leveling_up
		current_exp = @winner_pokemon.current_experience
		next_level_exp = @winner_pokemon.next_level_experience
		prev_level_exp = battle_exp.previous_level_exp(@winner_pokemon)
		@current_exp_percentage = 100*(current_exp-prev_level_exp)/(next_level_exp-prev_level_exp)

		if @level_up
			@waiting_moves = @winner_pokemon
								.default_moves
								.where(status: :Waiting, at_level: ..@winner_pokemon.level)
								.joins(:move)

			# evolution = PokemonEvolution.new
			# if evolution.evolve?(@winner_pokemon) && @waiting_moves.blank?
			# 	return redirect_to pokedex_evolution_path(@winner_pokemon)
			# end
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
		battle_exp = BattleExperience.new
		gained_exp = battle_exp.exp_calc(winner_pokemon, loser_pokemon)

		winner_pokemon.current_experience = winner_pokemon.current_experience+gained_exp

		# Set first level experience requirement
		if winner_pokemon.next_level_experience.blank?
			battle_exp.set_next_level_exp_requirement(winner_pokemon)
		end

		winner_pokemon.is_leveling_up = false

		while battle_exp.leveling_up?(winner_pokemon)
			battle_exp.level_up(winner_pokemon)
			winner_pokemon.is_leveling_up = true
		end

		unless winner_pokemon.save
			flash[:danger] = winner_pokemon.errors.full_messages[0]
		end
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
