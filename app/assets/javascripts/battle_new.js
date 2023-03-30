const DOC = document
function set_hp_bar (current_hp_percentage=false, which_pokemon) {
	current_hp_percentage = current_hp_percentage || 0;	
	DOC.querySelector(`#pokemon_${which_pokemon}_current_hp`).setAttribute('style', `width: ${current_hp_percentage}%;`)
}
function set_sprite (sprite_url=false, which_pokemon) {
	sprite_url = sprite_url || DOC.querySelector(`#pokemon_${which_pokemon}_sprite`).getAttribute('alt');
	DOC.querySelector(`#pokemon_${which_pokemon}_sprite`).setAttribute('src', sprite_url);
}

function calc_fraction_to_percentage (numerator=0, denumerator=0) {
	return 100*numerator/denumerator
}

function set_heal_path (pokemon, which_pokemon) {
	heal_path = pokemon ? `pokemons/heal/${pokemon.id}` : '#'
	class_list = DOC.querySelector(`#pokemon_${which_pokemon}_heal`).getAttribute('class');

	if (pokemon) {
		class_list = class_list.replace('disabled','');
	}else{
		class_list = class_list.includes('disabled') ? class_list : class_list.concat('disabled');
	}

	DOC.querySelector(`#pokemon_${which_pokemon}_heal`).setAttribute('href', heal_path);
	DOC.querySelector(`#pokemon_${which_pokemon}_heal`).setAttribute('class', class_list);
}

function set_form_status () {
	is_disabled = false;
	DOC.querySelectorAll('.pokemon_select').forEach((pokemon_select)=>{
		is_disabled = pokemon_select.value ? is_disabled : true;
	})
	
	is_disabled = is_duplicate_pokemon();
	DOC.querySelector(`[name="commit"]`).disabled = is_disabled;
}

function is_duplicate_pokemon () {
	is_disabled = true; 
	pokemon_1 = DOC.querySelector('#battle_pokemon_1_id').value;
	pokemon_2 = DOC.querySelector('#battle_pokemon_2_id').value;
	if (Boolean(pokemon_1) && Boolean(pokemon_2)) {
		is_disabled = pokemon_1 === pokemon_2; 
	}
	return is_disabled;
}

DOC.querySelectorAll('.pokemon_select').forEach((pokemon_select)=>{
	pokemon_select.addEventListener('change', (event) => {
		pokemon_id = event.target.selectedIndex-1;
		pokemon_number = event.target.dataset.target;
		pokemon = pokemons[pokemon_id];

		current_hp = pokemon_id !== -1 ? 
			calc_fraction_to_percentage(pokemon.current_hp, pokemon.maximum_hp) :
			0;
		sprite_url = pokemon_id !== -1 ? pokemon.image_url : false;

		set_form_status();
		set_hp_bar(current_hp, pokemon_number);
		set_sprite(sprite_url, pokemon_number);
		if (pokemon.current_hp < pokemon.maximum_hp) {
			set_heal_path(pokemon, pokemon_number);
		}
	})
})
