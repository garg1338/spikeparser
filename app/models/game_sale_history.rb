class GameSaleHistory < ActiveRecord::Base
	attr_accessible :occurred, :store, :price
	belongs_to :game
end
