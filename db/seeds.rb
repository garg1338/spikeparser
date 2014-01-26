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

GAME_REQUEST_BASE_URL = 'http://www.greenmangaming.com/search/?genres=action&page=2&o=saving'


result = Nokogiri::HTML(open(GAME_REQUEST_BASE_URL))
product_list= result.css("ul.product-list")
product_list_links = product_list.css("li a").map { |a| 
	a['href'] if a['href'].match("/games/")
	}.compact.uniq

product_list_links.each do |href|

	#grab the sale page for the game
	sale_link = 'http://www.greenmangaming.com' + href
	sale_page = Nokogiri::HTML(open(sale_link))

	#obtain the game title
	game_title = sale_page.css('h1.prod_det')
	game_title = /.*<h1 class="prod_det">(.*)<\/h1>.*/.match(game_title.to_s)
	puts game_title[1]
	puts "\n"


	#obtain description
	description_paragraphs = sale_page.css("section.description p")
	description = ""
	description_paragraphs.each do |paragraph|
		if !(paragraph.to_s.include? "<em>") && !(paragraph.to_s.include? "Features:")


			if(!paragraph.to_s.include? "<strong>")
				paragraph_text = (paragraph.to_s)[3...paragraph.to_s.length - 4]

			else
				paragraph_text = (paragraph.to_s)[11...paragraph.to_s.length - 13]
			end


			description += paragraph_text + "\n"

		end
	end

	#obtain normal price, current price
	current_price = sale_page.css("strong.curPrice")
	current_price = /.*<strong class="curPrice">(.*)<\/strong>.*/.match(current_price.to_s)
	puts current_price[1]


	if sale_page.to_s.include? "<span class=\"lt\">"
		normal_price = sale_page.css("span.lt")
		normal_price = /.*<span class="lt">(.*)<\/span>.*/.match(normal_price.to_s)
		puts normal_price[1]
	else
		puts "This game ain't on sale!"
	end

	puts "\n"



	#extract genres
	
	#obtain esrb rating
	
	#obtain release date


end








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