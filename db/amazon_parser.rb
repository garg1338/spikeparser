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



AMAZON_STORE_BASE_URL = 'http://www.amazon.com/s/ref=lp_2445220011_pg_2?rh=n%3A468642%2Cn%3A%2111846801%2Cn%3A979455011%2Cn%3A2445220011&page=2&ie=UTF8&qid=1391567690'

result = Nokogiri::HTML(open(APP_BASE_URL))

rows = result.css(".result.product")

rows.each do |row|
	# row_info = row.css("td")

	# row_info_2 = row_info[2].to_s

	# if row_info[1].to_s.include? "Game"
	# 	row_info_app_string = row_info[0].to_s
	# 	start_index = row_info_app_string.index('">')
	# 	end_index = row_info_app_string.index('</a>')
	# 	store_id = row_info_app_string[start_index+2...end_index]

	# 	url = STEAM_STORE_BASE_URL + store_id
	# 	page = SteamHelper.agePasser(url)
	# 	puts url
	# 	SteamHelper.extractPageInfo(page)

	puts row

	end
end

