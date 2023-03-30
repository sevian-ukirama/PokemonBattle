class CreateMove < ActiveRecord::Migration[6.1]
  def change
    create_table :moves do |t|
      t.string :name
      t.integer :type_id
      t.integer :maximum_pp

      t.timestamps
    end
  end
end
