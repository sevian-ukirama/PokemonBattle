class Pokemon < ApplicationRecord
	has_many :battles_as_pokemon_1, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_1_id', primary_key: 'id'
	has_many :battles_as_pokemon_2, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_2_id', primary_key: 'id'
	has_many :pokemon_moves
	has_many :moves, through: :pokemon_moves
	accepts_nested_attributes_for :pokemon_moves

	# Validates for presence
	validates :image_url, :name, :type_1_id, :maximum_hp, :current_hp, presence: true
	validates :attack, :defense, :speed, :special_attack, :special_defense, presence: true
	validates :move_1_id, :move_2_id, presence: true

	# Validates for negative/zero value
	validates_numericality_of :attack, :defense, :speed, :special_attack, :special_defense, greater_than: 0.0
	validates_numericality_of :current_hp, :maximum_hp, greater_than: 0.0

	enum type_id: ['Normal','Fire','Water','Grass','Electric','Ice','Fighting','Poison','Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon']
	enum status_id: ['Normal', 'Paralysis', 'Poison', 'Sleep', 'Frozen', 'Burn','Faint'], _prefix: :pokemon
end
