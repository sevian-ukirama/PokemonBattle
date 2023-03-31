const DOC = document;
const move_id_field = DOC.querySelector('#battle_submitted_move_id') ;
const move_row_order_field = DOC.querySelector('#battle_submitted_move_row_order') ;

DOC.querySelectorAll('.move-button').forEach((button)=>{
	button.onclick = (event)=>{
		const pressed_button = event.target;

		// Search for move ID & PP field and set Value
		move_id_field.value = parseInt(pressed_button.dataset.moveId);
		move_row_order_field.value = parseInt(pressed_button.dataset.moveRowOrder);

		// Submit Form
		DOC.querySelector('#battle').submit();
	}
})
