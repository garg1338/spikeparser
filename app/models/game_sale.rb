class GameSale < ActiveRecord::Base
	attr_accessible  :occurrence, :store, :url, :origamt, :saleamt
	belongs_to :game
end