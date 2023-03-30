class AddStatusEffectToMoves < ActiveRecord::Migration[6.1]
  def change
    add_column :moves, :status_effect_id, :integer
  end
end
