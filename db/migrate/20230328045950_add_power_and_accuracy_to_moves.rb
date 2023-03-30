class AddPowerAndAccuracyToMoves < ActiveRecord::Migration[6.1]
  def change
    add_column :moves, :power, :integer
    add_column :moves, :accuracy, :integer
  end
end
