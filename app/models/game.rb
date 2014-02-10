class Game < ActiveRecord::Base
  serialize :genres, Array
  attr_accessible :search_title, :coop, :description, :developer, :esrb_rating, :genres, :image_url, :metacritic_rating, :players, :publisher, :release_date, :title
  validates :title,  presence: true
  validates :search_title,  presence: true
  has_many :game_sales, dependent: :destroy
  has_many :game_sale_histories, dependent: :destroy
end
