# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


require 'nokogiri'
require 'open-uri'
require 'timeout'


# Game.delete_all

games_all = Game.all

games_all.each do |game|
	str = StringHelper.create_search_title(game.title)
	game.update_attributes(:search_title => str)
	game.save!
end



puts StringHelper.create_search_title("Warhammer® 40,000: Dawn of War® II Chaos Rising")
puts StringHelper.create_search_title("Warhammer 40,000: Dawn of War II - Chaos Rising")








