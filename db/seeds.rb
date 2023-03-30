# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Pokemon.create({
	name: 'Bulbasaur',
	type_1_id: 12,
	type_2_id: 4,
	current_hp: 45,
	maximum_hp: 45,
	speed: 45,
	attack: 49,
	defense: 49,
	special_attack: 65,
	special_defense: 65,
	status_id: 0,
	image_url: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'
},
{
	name: 'Ivysaur',
	type_1_id: 12,
	type_2_id: 4,
	current_hp: 60,
	maximum_hp: 60,
	speed: 60,
	attack: 62,
	defense: 63,
	special_attack: 80,
	special_defense: 80,
	status_id: 0,
	image_url: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/2.png'
})

