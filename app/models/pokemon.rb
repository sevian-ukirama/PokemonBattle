class Pokemon < ApplicationRecord
	has_many :battles_as_pokemon_1, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_1_id', primary_key: 'id'
	has_many :battles_as_pokemon_2, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_2_id', primary_key: 'id'
	has_many :default_moves, dependent: :destroy
	has_many :moves, through: :default_moves
	has_many :pokemon_moves, dependent: :destroy
	has_many :moves, through: :pokemon_moves
	has_many :evolutions_as_root_pokemon, dependent: :destroy, class_name: 'Evolution', foreign_key: 'root_pokemon_id', primary_key: 'id'
	has_many :evolutions_as_evolve_into, dependent: :destroy, class_name: 'Evolution', foreign_key: 'evolve_into_id', primary_key: 'id'
	has_many :evolutions_as_pokemon, dependent: :destroy, class_name: 'Evolution', foreign_key: 'pokemon_id', primary_key: 'id'
	accepts_nested_attributes_for :pokemon_moves, :default_moves

	# Validates for presence
	validates :image_url, :name, :type_1_id, :maximum_hp, :current_hp, presence: true, on: :create
	validates :attack, :defense, :speed, :special_attack, :special_defense, presence: true, on: :create

	# Validates for negative/zero value
	validates_numericality_of :attack, :defense, :speed, :special_attack, :special_defense, greater_than: 0.0, on: :create
	validates_numericality_of :current_hp, :maximum_hp, greater_than: 0.0, on: :create

	enum type_1_id: ['Normal','Fire','Water','Grass','Electric','Ice','Fighting','Poison','Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon'], _prefix: :type_1
	enum type_2_id: ['Normal','Fire','Water','Grass','Electric','Ice','Fighting','Poison','Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon'], _prefix: :type_2
	enum status_id: ['Normal','Paralysis','Poison','Sleep','Frozen','Burn','Faint'], _prefix: :status

end
