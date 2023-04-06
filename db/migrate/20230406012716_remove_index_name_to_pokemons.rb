class RemoveIndexNameToPokemons < ActiveRecord::Migration[6.1]
  def change
    remove_index :pokemons, column: :name
  end
end
