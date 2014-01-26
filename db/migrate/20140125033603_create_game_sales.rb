class CreateGameSales < ActiveRecord::Migration
  def change
    create_table :game_sales do |t|
      t.integer :game_id
      t.datetime :occurrence
      t.string :store
      t.string :url
      t.float :origamt
      t.float :saleamt

      t.timestamps
    end
  end
end
