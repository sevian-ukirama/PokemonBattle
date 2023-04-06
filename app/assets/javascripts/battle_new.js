const DOC = document
function set_hp_bar (current_hp_percentage, pokemon_number) {
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

function clear_heal_path (pokemon_number) {
	let pokemon_heal_dom = DOC.querySelector(`#pokemon_${pokemon_number}_heal`)
	pokemon_heal_dom.setAttribute('href', '#');
	pokemon_heal_dom.classList.add('disabled');
}

function set_heal_path (pokemon, pokemon_number) {
	let heal_path = pokemon ? `/pokemons/heal/${pokemon.id}` : '#'
	let pokemon_heal_dom = DOC.querySelector(`#pokemon_${pokemon_number}_heal`)

	if (pokemon) {
		pokemon_heal_dom.classList.remove('disabled');
	}else{
		pokemon_heal_dom.classList.add('disabled');
	}

	pokemon_heal_dom.setAttribute('href', heal_path);
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
	pokemon_moveset = pokemon_moves.filter(move => move.pokemon_id == pokemon.id);

	pokemon_moveset.forEach((pokemon_move, index)=>{
		let move = moves.find(m => m.id == pokemon_move.move_id );
		pokemon_move.name = move.name;
		pokemon_move.maximum_pp = move.maximum_pp;
	})
	return pokemon_moveset;
}

DOC.querySelectorAll('.pokemon_select').forEach((pokemon_select)=>{
	pokemon_select.addEventListener('change', (event) => {
		pokemon_id = event.target.selectedIndex-1;
		pokemon_number = event.target.dataset.target;
		pokemon = pokemons[pokemon_id];

		maximum_hp = pokemon.maximum_hp;
		current_hp = pokemon_id !== -1 ? 
			calc_fraction_to_percentage(pokemon.current_hp, maximum_hp) :
			0;
		sprite_url = pokemon_id !== -1 ? pokemon.image_url : false;

		set_form_status();
		set_hp_bar(current_hp, pokemon_number);
		set_sprite(sprite_url, pokemon_number);

		clear_move_pills(pokemon_number);
		clear_heal_path(pokemon_number);

		// If Pokemon not valid, guard clause
		if (!pokemon) { return; }

		// If Pokemon valid
		if (pokemon.current_hp < pokemon.maximum_hp) {
			set_heal_path(pokemon, pokemon_number);
		}

		const MOVESET = set_pokemon_moveset(pokemon);
		MOVESET.forEach((move, index)=>{
			append_move_pill(pokemon_number, create_move_pill(move));
		})

	})
})
