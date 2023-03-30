class CreatePokemonMove < ActiveRecord::Migration[6.1]
  def change
    create_table :pokemon_moves do |t|
      t.references :pokemon, null: false, foreign_key: true
      t.references :move, null: false, foreign_key: true
      t.integer :row_order
      t.integer :current_pp

      t.timestamps
    end
  end
end
