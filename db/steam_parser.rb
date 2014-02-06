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
require 'restclient'


APP_BASE_URL = 'http://steamdb.info/apps/page1/'

STEAM_STORE_BASE_URL = 'http://store.steampowered.com/app/'

result = Nokogiri::HTML(open(APP_BASE_URL))

rows = result.css("table#table-apps")

rows = rows.css("tbody")
rows = rows.css("tr")

rows.each do |row|
	row_info = row.css("td")

	row_info_2 = row_info[2].to_s

	if row_info[1].to_s.include? "Game"
		row_info_app_string = row_info[0].to_s
		start_index = row_info_app_string.index('">')
		end_index = row_info_app_string.index('</a>')
		store_id = row_info_app_string[start_index+2...end_index]

		url = STEAM_STORE_BASE_URL + store_id
		page = SteamHelper.agePasser(url)
		puts url
		SteamHelper.extractPageInfo(page)

	end
end








# GAME_REQUEST_BASE_URL = 'http://store.steampowered.com/search/?term=#category1=998&sort_order=ASC&page=6'



# result = Nokogiri::HTML(open(GAME_REQUEST_BASE_URL))

# products = result.css('a[href].search_result_row')


# products.each do |product|
# 	index = product.to_s.index("class")
# 	product_link = (product.to_s)[9...index-2]
# 	page = SteamHelper.agePasser(product_link)
# 	puts product_link
# 	SteamHelper.extractPageInfo(page)
# end




# class CreateGames < ActiveRecord::Migration
#   def change
#     create_table :games do |t|
#       t.string :title
#       t.string :platform
#       t.string :release_date
#       t.string :description
#       t.string :esrb_rating
#       t.string :players
#       t.string :coop
#       t.string :publisher
#       t.string :developer
#       t.string :genres
#       t.string :metacritic_rating
#       t.string :image_url

#       t.timestamps
#     end
#   end
# end