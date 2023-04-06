class Evolution < ApplicationRecord
	belongs_to :root_pokemon, class_name: 'Pokemon'
	belongs_to :evolve_into, class_name: 'Pokemon'
	belongs_to :pokemon, class_name: 'Pokemon'
	
	enum status: ['Waiting','Accepted','Rejected']
end
