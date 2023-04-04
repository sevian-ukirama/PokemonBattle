class AddBaseExpToPokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :pokemons, :base_experience, :integer
  end
end
