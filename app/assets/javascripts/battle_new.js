const DOC = document
function set_hp_bar (current_hp_percentage=false, pokemon_number) {
	current_hp_percentage = current_hp_percentage || 0;	
	DOC.querySelector(`#pokemon_${pokemon_number}_current_hp`).setAttribute('style', `width: ${current_hp_percentage}%;`)
}
function set_sprite (sprite_url=false, pokemon_number) {
	sprite_url = sprite_url || DOC.querySelector(`#pokemon_${pokemon_number}_sprite`).getAttribute('alt');
	DOC.querySelector(`#pokemon_${pokemon_number}_sprite`).setAttribute('src', sprite_url);
}

function calc_fraction_to_percentage (numerator=0, denumerator=0) {
	return 100*numerator/denumerator
}

function set_heal_path (pokemon, pokemon_number) {
	heal_path = pokemon ? `/pokemons/heal/${pokemon.id}` : '#'
	class_list = DOC.querySelector(`#pokemon_${pokemon_number}_heal`).getAttribute('class');

	if (pokemon) {
		class_list = class_list.replace('disabled','');
	}else{
		class_list = class_list.includes('disabled') ? class_list : class_list.concat('disabled');
	}

	DOC.querySelector(`#pokemon_${pokemon_number}_heal`).setAttribute('href', heal_path);
	DOC.querySelector(`#pokemon_${pokemon_number}_heal`).setAttribute('class', class_list);
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

function clear_move_pills (pokemon_number) {
	let pokemon_moves_dom = DOC.querySelector(`#pokemon_${pokemon_number}_moves`);
	pokemon_moves_dom.innerHTML = '';
}

function append_move_pill (pokemon_number, element) {
	let pokemon_moves_dom = DOC.querySelector(`#pokemon_${pokemon_number}_moves`);
	pokemon_moves_dom.appendChild(element);
}

function create_move_pill (move) {
	let move_pill = DOC.createElement('p');

	move_pill.classList.add('btn','btn-warning','font-weight-bold','px-2','py-1','mx-1');
	if (parseInt(move.current_pp) === 0) {
		move_pill.classList.remove('btn-warning');
		move_pill.classList.add('disabled','btn-outline-secondary');
	}
	move_pill.innerText = `${move.name} (${move.current_pp}/${move.maximum_pp})`;

	return move_pill;
}

function set_pokemon_moveset (pokemon) {
	moveset = pokemon_moves.filter(move => move.pokemon_id == pokemon.id);
	moveset.forEach((move, index)=>{
		move.name = moves[index].name
		move.maximum_pp = moves[index].maximum_pp
	})
	return moveset;
}

// console.log(pokemon_moves)
// console.log(moves)

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

		const MOVESET = set_pokemon_moveset(pokemon);
		clear_move_pills(pokemon_number);
		MOVESET.forEach((move, index)=>{
			append_move_pill(pokemon_number, create_move_pill(move));
		})

	})
})
