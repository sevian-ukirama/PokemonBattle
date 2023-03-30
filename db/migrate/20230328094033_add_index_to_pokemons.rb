class AddIndexToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_index :pokemons, :name, unique: true
    add_index :moves, :name, unique: true
  end
end
