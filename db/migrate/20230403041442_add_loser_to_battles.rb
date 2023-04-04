class AddLoserToBattles < ActiveRecord::Migration[6.1]
  def change
    add_reference :battles, :loser_pokemon, null: true, foreign_key: { to_table: :pokemons }
  end
end
