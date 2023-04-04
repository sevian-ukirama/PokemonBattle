class DefaultMove < ApplicationRecord
	belongs_to :pokemon, class_name: 'Pokemon'
	belongs_to :move, class_name: 'Move'

	enum status: ['Waiting','Accepted','Rejected']
end
