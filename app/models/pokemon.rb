class Pokemon < ApplicationRecord
	has_many :battles_as_pokemon_1, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_1_id', primary_key: 'id'
	has_many :battles_as_pokemon_2, dependent: :destroy, class_name: 'Battle', foreign_key: 'pokemon_2_id', primary_key: 'id'
	has_many :default_moves
	has_many :moves, through: :default_moves
	has_many :pokemon_moves
	has_many :moves, through: :pokemon_moves
	accepts_nested_attributes_for :pokemon_moves, :default_moves

	# Validates for presence
	validates :image_url, :name, :type_1_id, :maximum_hp, :current_hp, presence: true, on: :create
	validates :attack, :defense, :speed, :special_attack, :special_defense, presence: true, on: :create

	# Validates for negative/zero value
	validates_numericality_of :attack, :defense, :speed, :special_attack, :special_defense, greater_than: 0.0, on: :create
	validates_numericality_of :current_hp, :maximum_hp, greater_than: 0.0, on: :create

	enum type_1_id: {'Normal': 1,'Fire': 2,'Water': 3,'Grass': 4,'Electric': 5,'Ice': 6,'Fighting': 7,'Poison': 8,'Ground': 9, 'Flying': 10, 'Psychic': 11, 'Bug': 12, 'Rock': 13, 'Ghost': 14, 'Dragon': 15}, _prefix: :type_1
	enum type_2_id: {'Normal': 1,'Fire': 2,'Water': 3,'Grass': 4,'Electric': 5,'Ice': 6,'Fighting': 7,'Poison': 8,'Ground': 9, 'Flying': 10, 'Psychic': 11, 'Bug': 12, 'Rock': 13, 'Ghost': 14, 'Dragon': 15}, _prefix: :type_2
	enum status_id: {'Normal': 1,'Paralysis': 2,'Poison': 3,'Sleep': 4,'Frozen': 5,'Burn': 6,'Faint': 7}, _prefix: :status

end
