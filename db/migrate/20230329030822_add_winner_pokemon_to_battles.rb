class AddWinnerPokemonToBattles < ActiveRecord::Migration[6.1]
  def change
    add_reference :battles, :winner_pokemon, foreign_key: { to_table: :pokemons }
  end
end
