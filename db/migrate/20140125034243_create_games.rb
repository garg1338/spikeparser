class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :title
      t.string :platform
      t.date   :release_date
      t.string :description
      t.string :players 
      t.string :esrb_rating
      t.string :coop
      t.string :publisher
      t.string :developer
      t.string :genres
      t.string :metacritic_rating
      t.string :image_url

      t.timestamps
    end
  end
end
