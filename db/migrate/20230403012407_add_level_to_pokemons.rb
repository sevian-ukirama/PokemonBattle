class AddLevelToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :level, :integer
  end
end
