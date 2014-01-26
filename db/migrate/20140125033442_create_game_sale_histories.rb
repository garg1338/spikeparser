class CreateGameSaleHistories < ActiveRecord::Migration
  def change
    create_table :game_sale_histories do |t|
      t.datetime :occurred
      t.integer :game_id
      t.string :store
      t.float :price

      t.timestamps
    end
  end
end
