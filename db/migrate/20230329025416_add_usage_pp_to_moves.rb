class AddUsagePpToMoves < ActiveRecord::Migration[6.1]
  def change
    add_column :moves, :usage_pp, :integer, default: 1
  end
end
