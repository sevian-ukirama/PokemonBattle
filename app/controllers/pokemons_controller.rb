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
			redirect_to pokemons_path
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
			redirect_to new_battle_path
		end

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

		pokemon_moves = params[:pokemon][:pokemon_moves]
		pokemon_moves.each.with_index do |move, index|
			move_id = move[1]
			move_from_db = nil
			pokemon_move = {}
			unless move_id.blank?
				move_from_db = Move.find(move_id)
				puts 'Move ', move_from_db.to_json
				pokemon_move.row_order = index+1
				pokemon_move.current_pp = move_from_db.maximum_pp
			end
			pokemon_move = pokemon.pokemon_moves.build(move: move_from_db)
			puts 'Hello ', pokemon_move.to_json
		end

		if pokemon.save
			flash[:success] = "Pokemons Saved"
		else
			flash[:danger] = pokemon.errors.full_messages[0]
		end

		redirect_to new_pokemon_path
	end

end
