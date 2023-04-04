class AddLevelingUpToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :is_leveling_up, :boolean, default: false
  end
end
