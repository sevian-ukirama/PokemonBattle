class PokemonsController < ApplicationController
	require 'Pokemon/Evolution'
	require 'Pokemon/LearnMove'

	before_action :is_pokemon_exist?, except: [:create]

	def index
		@pokemons = Pokemon.order(name: :asc)
	end

	def new
		@moves = Move.all
		@types = Rails.configuration.PokemonBattle[:TYPES]
	end

	def heal
		if params[:id].blank?
			pokemons = Pokemon.all

			pokemons.each do |pokemon|
				pokemon.current_hp = pokemon.maximum_hp
				pokemon.status_id = 'Normal'

				pokemon.pokemon_moves.each do |pokemon_move|
					pokemon_move.current_pp = pokemon_move.move.maximum_pp
				end

				unless pokemon.save
					flash[:danger] = pokemon.errors.full_messages[0]
				end
			end

			flash[:success] = 'All Pokemon has been Healed'
		else
			pokemon = Pokemon.find(params[:id])
			pokemon.current_hp = pokemon.maximum_hp
			pokemon.status_id = 'Normal'

			pokemon.pokemon_moves.each do |pokemon_move|
				pokemon_move.current_pp = pokemon_move.move.maximum_pp
			end

			unless pokemon.save
				flash[:danger] = pokemon.errors.full_messages[0]
			end

			flash[:success] = "#{pokemon.name} has been Healed"
		end

		redirect_back(fallback_location: root_url)
	end

	def create
		# Build first, only one save, Nested should follow 
		pokemon = Pokemon.new

		pokemon.name = params[:pokemon][:name].capitalize
		pokemon.image_url = params[:pokemon][:image_url]
		pokemon.type_1_id = params[:pokemon][:type_1_id]
		pokemon.type_2_id = params[:pokemon][:type_2_id]
		pokemon.current_hp = params[:pokemon][:maximum_hp]
		pokemon.maximum_hp = params[:pokemon][:maximum_hp]
		pokemon.attack = params[:pokemon][:attack]
		pokemon.defense = params[:pokemon][:defense]
		pokemon.speed = params[:pokemon][:speed]
		pokemon.special_attack = params[:pokemon][:special_attack]
		pokemon.special_defense = params[:pokemon][:special_defense]

		pokemon_moves = params[:pokemon][:moves]
		pokemon_moves.first(4).each.with_index do |move, index|
			move_id = move[1]
			unless move_id.blank?
				move_from_db = Move.find(move_id)
				pokemon_move = pokemon.pokemon_moves.build(move: move_from_db)
				pokemon_move.row_order = index+1
				pokemon_move.current_pp = move_from_db.maximum_pp
			end
		end

		# RecordNotUnique Rescue
		begin
			if pokemon.save
				flash[:success] = "#{pokemon.name} Created."
			else
				flash[:danger] = pokemon.errors.full_messages[0]
			end
		rescue ActiveRecord::RecordNotUnique => e
			flash[:danger] = "Pokemon is not allowed to have multiple same moves."
		end

		redirect_to pokemon_path(pokemon)
	end

	def show
		@pokemon = Pokemon.find_by(id: params[:id])
		@pokemon_moves = @pokemon.pokemon_moves
		@types = Rails.configuration.PokemonBattle[:TYPES]
		@moves = Move.all
	end

	def update
		pokemon = Pokemon.find_by(id: params[:id])

		pokemon.name = params[:pokemon][:name].capitalize
		pokemon.image_url = params[:pokemon][:image_url]
		pokemon.type_1_id = params[:pokemon][:type_1_id]
		pokemon.type_2_id = params[:pokemon][:type_2_id]
		pokemon.current_hp = params[:pokemon][:maximum_hp]
		pokemon.maximum_hp = params[:pokemon][:maximum_hp]
		pokemon.attack = params[:pokemon][:attack]
		pokemon.defense = params[:pokemon][:defense]
		pokemon.speed = params[:pokemon][:speed]
		pokemon.special_attack = params[:pokemon][:special_attack]
		pokemon.special_defense = params[:pokemon][:special_defense]

		pokemon_moves = pokemon.pokemon_moves.destroy_all

		pokemon_moves = params[:pokemon][:moves]
		pokemon_moves.each.with_index do |move, index|
			move_id = move[1]
			unless move_id.blank?
				move_from_db = Move.find(move_id)
				pokemon_move = pokemon.pokemon_moves.build(move: move_from_db)
				pokemon_move.row_order = index+1
				pokemon_move.current_pp = move_from_db.maximum_pp
			end
		end

		# RecordNotUnique Rescue
		begin
			if pokemon.save
				flash[:success] = "#{pokemon.name} Updated."
			else
				flash[:danger] = pokemon.errors.full_messages[0]
			end
		rescue ActiveRecord::RecordNotUnique => e
			flash[:danger] = "Pokemon is not allowed to have multiple same moves."
		end

		redirect_back(fallback_location: pokemon_path(pokemon))
	end

	def learn_moves
		pokemon = Pokemon.find_by(id: params[:id])
		waiting_moves = params[:waiting].each.filter {|k,v| v.to_i == 1}
		learned_moves = params[:learned].each.filter {|k,v| v.to_i == 1}

		# NEED TO REFACTOR 
		waiting_moves.first(4).each.with_index do |waiting_move, index|
			default_move = pokemon.default_moves.joins(:move).find_by(move: waiting_move[0])
			# If move is not for the Pokemon
			if default_move.blank?
				flash[:danger] = "Move not Found"
				return redirect_back(fallback_location: root_url)
			end

			pokemon_move_all = pokemon.pokemon_moves
			learned = pokemon_move_all.find_by(move: waiting_move[0])
			# If move is not learned yet
			if learned.blank?
				move_to_replace = learned_moves[index]

				# If there's move to replace
				if !move_to_replace.blank?
					move_to_replace = pokemon.pokemon_moves.find_by(move: learned_moves[index][0])
					move_to_replace.update(move_id: default_move.move_id, current_pp: default_move.move.maximum_pp)

					# Update Waiting move Status
					default_move.update(status: 'Accepted')
					flash[:success] = "#{pokemon.name} has learned new moves!"

				# If there's no move to replace and pokemon don't have 4 moves yet
				elsif pokemon_move_all.length < 4
					pokemon_move = pokemon.pokemon_moves.build
					pokemon_move.move_id = default_move.move_id
					pokemon_move.current_pp = default_move.move.maximum_pp
					pokemon_move.row_order = pokemon.pokemon_moves.maximum(:row_order)+1

					unless pokemon.save
						flash[:danger] = pokemon.errors.full_messages[0]
					end

					# Update Waiting move Status
					default_move.update(status: 'Accepted')
					flash[:success] = "#{pokemon.name} has learned new moves!"
				else
					flash[:danger] = "#{pokemon.name} already know 4 moves!"
				end


			else
				flash[:danger] = "Move already learned"
			end

		end

		moves = PokemonLearnMove.new
		moves.reject_waiting(pokemon)

		redirect_back(fallback_location: root_url)
	end

	# Render Evolution
	def evolution
		@pokemon = Pokemon.find_by(id: params[:id])
		@evolve = false

		evolution = PokemonEvolution.new
		if evolution.evolve?(@pokemon)
			@next_pokemon = evolution.next_pokemon(@pokemon)
			@evolve = true
		end
	end

	# START EVOLVE
	def evolve
		confirm = params[:commit].downcase == 'yes'

		# Get Current > Root > Latest
		pokemon = Pokemon.find_by(id: params[:id])
		evolution = PokemonEvolution.new

		if confirm
			next_pokemon = evolution.next_pokemon(pokemon)
			prev_pokemon_name = pokemon.name
			evolution_status = evolution.evolve(pokemon)
			if evolution_status
				flash[:success] = "Congatulations! #{prev_pokemon_name} has evolved into #{next_pokemon.name}!"
			else
				flash[:danger] = evolution_status 
			end
		else
			flash[:warning] = "#{pokemon.name} rejected the evolution!"
			evolution.reject_evolution(pokemon)
		end

		redirect_to pokemon_path(pokemon)
	end
	# END EVOLVE

	def destroy
		pokemon = Pokemon.find_by(id: params[:id])
		unless pokemon.destroy
			flash[:danger] = pokemon.errors.full_messages
		end

		flash[:warning] = "#{pokemon.name} is Deleted!"

		redirect_to pokemons_path
	end

	private

	def is_pokemon_exist?
		pokemon = Pokemon.find_by(id: params[:id])
		if pokemon.blank? && !params[:id].blank?
			flash[:danger] = "Pokemon Not Found"
			redirect_to root_url
		end
	end

end
