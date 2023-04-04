class CreateEvolution < ActiveRecord::Migration[6.1]
  def change
    create_table :evolutions do |t|
      t.references :pokemon, null: false, foreign_key: { to_table: :pokemons }
      t.references :evolve_into, null: false, foreign_key: { to_table: :pokemons }
      t.references :root_pokemon, null: false, foreign_key: { to_table: :pokemons }
      t.integer :at_level
      t.integer :status

      t.timestamps
    end
  end
end
