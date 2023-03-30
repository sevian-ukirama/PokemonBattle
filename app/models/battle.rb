class Battle < ApplicationRecord
	belongs_to :pokemon_1, class_name: 'Pokemon'
	belongs_to :pokemon_2, class_name: 'Pokemon'

	# Connects to Pokemon_Moves, through Pokemons
	# Flow: Battle > Pokemons > Pokemon_Moves
	has_many :pokemon_1_moves, through: :pokemon_1, source: :pokemon_moves 
	has_many :pokemon_2_moves, through: :pokemon_2, source: :pokemon_moves 

	# Connects to Moves through Pokemon_Moves, through Pokemons
	# Flow: Battle > Pokemons > Pokemon_Moves > Moves
	has_many :pokemon_1_move_moves, through: :pokemon_1_moves, source: :moves 
	has_many :pokemon_2_move_moves, through: :pokemon_2_moves, source: :moves 

	before_save :check_duplicate_pokemons
	before_save :check_duplicate_pokemons

	enum status_id: [:ongoing, :finished]

	private

	def check_duplicate_pokemons
		if pokemon_1.id == pokemon_2.id
			errors.add(:pokemon_1_id, "can't be the same as pokemon 2") 
			redirect_to new_battle_path
		end
	end
end
