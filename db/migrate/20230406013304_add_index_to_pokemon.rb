class AddIndexToPokemon < ActiveRecord::Migration[6.1]
  def change
    add_index :pokemons, [:id, :name], unique: true
  end
end
