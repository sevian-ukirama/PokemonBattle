class PokemonsController < ApplicationController

	def index
		@pokemons = Pokemon.all
	end

	def new
		@moves = Move.all
		@types = Rails.configuration.PokemonBattle[:POKEMON_TYPES]
	end

	def heal
		if params[:id].blank?
			pokemons = Pokemon.where('current_hp < maximum_hp')

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
		else
			pokemon = Pokemon.find(params[:id])
			pokemon.current_hp = pokemon.maximum_hp
			pokemon.status_id = 'Normal'

			unless pokemon.save
				flash[:danger] = pokemon.errors.full_messages[0]
			end
		end

		flash[:success] = 'Pokemons has been Healed'
		redirect_to pokemons_path
	end

	def create
		# Build first, only one save, Nested should follow 
		pokemon = Pokemon.new

		pokemon.name = params[:pokemon][:name]
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

		4.times do |index|
			move_from_db = Move.find(params[:pokemon]["move_#{index+1}_id"])
			pokemon_move = pokemon.pokemon_moves.build(move: move_from_db)
			pokemon_move.row_order = index+1
			pokemon_move.current_pp = move_from_db.maximum_pp
		end

		if pokemon.save
			flash[:success] = "Pokemons Saved"
		else
			flash[:danger] = pokemon.errors.full_messages[0]
		end

		redirect_to new_pokemon_path
	end

end
