class AddCurrentExpToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :current_experience, :integer
  end
end
