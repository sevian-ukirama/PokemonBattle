class AddBackstoryToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :backstory, :text
  end
end
