class AddNextLevelToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :next_level_experience, :integer
  end
end
