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

i = 1

until i == 300
	APP_BASE_URL = 'http://steamdb.info/apps/page' + i.to_s + '/'

	STEAM_STORE_BASE_URL = 'http://store.steampowered.com/app/'

	result = Nokogiri::HTML(open(APP_BASE_URL))

	rows = result.css("table#table-apps")

	rows = rows.css("tbody")
	rows = rows.css("tr")

	rows.each do |row|
		row_info = row.css("td")

		row_info_2 = row_info[2].to_s

		if row_info[1].to_s.include? "Game" or row_info[1].to_s.include? "DLC"
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
	i = i + 1;
end








