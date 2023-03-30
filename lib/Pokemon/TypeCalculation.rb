class PokemonTypeChart
	def effectiveness(move_type, target_type)
		effectiveness = 1
		if move_type == 'Normal' 
			case target_type
			when 'Rock'
				effectiveness = 0.5 
			when 'Ghost'
				effectiveness = 0
			end
		elsif move_type == 'Fire'
			case target_type
			when 'Fire','Water','Rock','Dragon'
				effectiveness = 0.5
			when 'Grass','Ice','Bug'
				effectiveness = 2
			end 
		elsif move_type == 'Water' 
			case target_type
			when 'Water','Grass','Dragon'
				effectiveness = 0.5
			when 'Fire','Ground','Rock'
				effectiveness = 2
			end 
		elsif move_type == 'Grass' 
			case target_type
			when 'Fire','Grass','Poison','Flying','Bug','Dragon'
				effectiveness = 0.5
			when 'Water','Ground','Rock'
				effectiveness = 2
			end 
		elsif move_type == 'Electric' 
			case target_type
			when 'Ground'
				effectiveness = 0
			when 'Electric','Grass','Dragon'
				effectiveness = 0.5
			when 'Water','Flying'
				effectiveness = 2
			end 
		elsif move_type == 'Ice' 
			case target_type
			when 'Water','Ice'
				effectiveness = 0.5
			when 'Grass','Ground','Flying','Dragon'
				effectiveness = 2
			end  
		elsif move_type == 'Fighting' 
			case target_type
			when 'Ghost'
				effectiveness = 0
			when 'Poison','Flying','Psychic','Bug'
				effectiveness = 0.5
			when 'Fighting','Ice','Rock'
				effectiveness = 2
			end  
		elsif move_type == 'Poison'
			case target_type
			when 'Poison','Ground','Rock','Ghost'
				effectiveness = 0.5
			when 'Grass','Bug'
				effectiveness = 2
			end   
		elsif move_type == 'Ground' 
			case target_type
			when 'Flying'
				effectiveness = 0
			when 'Grass','Bug'
				effectiveness = 0.5
			when 'Fire','Electric','Poison','Rock'
				effectiveness = 2
			end  
		elsif move_type == 'Flying' 
			case target_type
			when 'Electric','Rock'
				effectiveness = 0.5
			when 'Grass','Fighting','Bug'
				effectiveness = 2
			end  
		elsif move_type == 'Psychic' 
			case target_type
			when 'Psychic'
				effectiveness = 0.5
			when 'Fighting','Poison'
				effectiveness = 2
			end  
		elsif move_type == 'Bug' 
			case target_type
			when 'Fire','Fighting','Flying','Dragon'
				effectiveness = 0.5
			when 'Grass','Poison','Psychic'
				effectiveness = 2
			end  
		elsif move_type == 'Rock' 
			case target_type
			when 'Fighting','Ground'
				effectiveness = 0.5
			when 'Fire','Ice','Flying','Bug'
				effectiveness = 2
			end  
		elsif move_type == 'Ghost'
			case target_type
			when 'Normal','Psychic'
				effectiveness = 0
			when 'Ghost'
				effectiveness = 2
			end   
		elsif move_type == 'Dragon'
			case target_type
			when 'Dragon'
				effectiveness = 2
			end   
		end
		return effectiveness
	end

	def status_resistant?(move_status_effect, target_type_1)
		resistance = false
		if (target_type_1 == 'Fire' && move_status_effect = 'Burn') ||
			(target_type_1 == 'Ice' && move_status_effect = 'Frozen') ||
			(target_type_1 == 'Poison' && move_status_effect = 'Poison') ||
			(target_type_1 == 'Electric' && move_status_effect = 'Paralysis')
			
			resistance = true
		end
		return resistance
	end
end