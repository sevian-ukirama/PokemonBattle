const DOC = document;
const move_id_field = DOC.querySelector('#battle_submitted_move_id') ;
const move_pp_field = DOC.querySelector('#battle_submitted_move_pp') ;

DOC.querySelectorAll('.move-button').forEach((button)=>{
	button.onclick = (event)=>{
		const pressed_button = event.target;

		// Search for move ID & PP field and set Value
		move_id_field.value = parseInt(pressed_button.dataset.moveId);
		move_pp_field.value = parseInt(pressed_button.dataset.movePp);

		// Submit Form
		DOC.querySelector('#battle').submit();
	}
})
