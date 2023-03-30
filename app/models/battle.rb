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

	# Validates presence
	validates :pokemon_1, presence: true
	validates :pokemon_2, presence: true

	# Custom validation
	validate :not_duplicate_pokemons
	validate :pp_not_zero
	validate :hp_not_zero
	validate :pokemons_not_in_battle

	enum status_id: [:ongoing, :finished]

	private

	def not_duplicate_pokemons
		if self.pokemon_1 == self.pokemon_2
			errors.add(:pokemon_1, " can't be the same as Pokemon 2")
		end
	end

	def pp_not_zero
		pokemon_1_all_pp_zero = false

		self.pokemon_1.pokemon_moves.each do |move|
			pokemon_1_all_pp_zero = move.current_pp.zero?
		end

		if pokemon_1_all_pp_zero
			errors.add(:pokemon_1, " has no valid Moves")
		end

		pokemon_2_all_pp_zero = false

		self.pokemon_2.pokemon_moves.each do |move|
			pokemon_2_all_pp_zero = move.current_pp.zero?
		end

		if pokemon_2_all_pp_zero
			errors.add(:pokemon_2, " has no valid Moves")
		end
	end

	def hp_not_zero
		if pokemon_1.current_hp.zero?
			errors.add(:pokemon_1, " has no HP")
		end

		if pokemon_2.current_hp.zero?
			errors.add(:pokemon_2, " has no HP")
		end
	end

	def pokemons_not_in_battle
		# Ongoing in DB Battles represented as 0 (int)
		ongoing = 0;
		if Battle.where(pokemon_1_id: pokemon_1.id).where(status_id: ongoing).exists?
			errors.add(:pokemon_1, " already in Battle")
		elsif Battle.where(pokemon_2_id: pokemon_2.id).where(status_id: ongoing).exists?
			errors.add(:pokemon_2, " already in Battle")
		end
	end

end
