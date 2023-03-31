class AddIndexToPokemonMoves < ActiveRecord::Migration[6.1]
  def change
    add_index :pokemon_moves, [:pokemon_id, :move_id], unique: true
  end
end
