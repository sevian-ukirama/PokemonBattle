class CreateBattle < ActiveRecord::Migration[6.1]
  def change
    create_table :battles do |t|
      t.references :pokemon_1, null: false, foreign_key: { to_table: :pokemons }
      t.references :pokemon_2, null: false, foreign_key: { to_table: :pokemons }
      t.integer :turn_number
      t.integer :status

      t.timestamps
    end
  end
end
