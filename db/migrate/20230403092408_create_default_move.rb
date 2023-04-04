class CreateDefaultMove < ActiveRecord::Migration[6.1]
  def change
    create_table :default_moves do |t|
      t.references :pokemon, null: false, foreign_key: { to_table: :pokemons }
      t.references :move, null: false, foreign_key: { to_table: :moves }
      t.integer :at_level
      t.integer :status

      t.timestamps
    end
  end
end
