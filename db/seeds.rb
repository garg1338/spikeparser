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



AMAZON_STORE_BASE_URL = 'http://www.amazon.com/gp/search/ref=sr_pg_11?rh=n%3A468642%2Cn%3A%2111846801%2Cn%3A979455011%2Cn%3A2445220011&page=11&ie=UTF8&qid=1391573730&lo=none'

result = Nokogiri::HTML(open(AMAZON_STORE_BASE_URL))

rows = result.css(".result.product")

rows.each do |row|

	puts row

	title = row.css("a.title")

	title = title.to_s

	title_start = title.index('">')
	title_end = title.index("[")

	# title = title[title_start+2...title_end]

	puts title

	row_string = row.to_s
	purchase_options = row_string.split("</tr>")

	purchase_options.each do |purchase_option|
		if purchase_option.include? "PC Download"
			chunk_start_index = purchase_option.index('toeOurPrice">')
			if chunk_start_index != nil
				purchase_option_chunk = purchase_option[chunk_start_index...purchase_option.length]
				chunk_end_index = purchase_option_chunk.index("</td>")
				purchase_option_chunk = purchase_option_chunk[0...chunk_end_index]
				start_index = purchase_option_chunk.index('$')
				end_index = purchase_option_chunk.index("</a>")
				sale_price = purchase_option_chunk[start_index...end_index]
				puts sale_price
			end
		end
	end
end


