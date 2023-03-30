class CreatePokemon < ActiveRecord::Migration[6.1]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.integer :current_hp
      t.integer :maximum_hp
      t.integer :speed
      t.integer :attack
      t.integer :defense
      t.integer :special_attack
      t.integer :special_defense
      t.integer :type_1_id
      t.integer :type_2_id
      t.integer :status_id

      t.timestamps
    end
  end
end
