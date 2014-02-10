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

GAME_REQUEST_BASE_URL = 'http://thegamesdb.net/api/GetGame.php?id=' 

METACRITIC_REQUEST_BASE_URL = 'http://www.metacritic.com/game/'

GAME_BASE_IMAGE_URL = "http://thegamesdb.net/banners/"



VIABLE_CONSOLE_LIST = ["PC"]

CONSOLE_TO_METACRITIC_MAP = Hash.new("fuck")

CONSOLE_TO_METACRITIC_MAP["PC"] = "pc"





client = Gamesdb::Client.new
platforms = client.platforms.all


	platforms.each do |platform| unless !(VIABLE_CONSOLE_LIST.include?(platform.name))
		puts(platform.name)
		puts("in it")
		platform_games_wrapper = client.get_platform_games(platform.id)
		platform_games = platform_games_wrapper["Game"]
		if (!(platform_games.nil?) && platform.id != "4914")
			platform_games.each do |platform_game|
				id = platform_game["id"]
				game = client.get_game(id)["Game"]
				request_url = "#{GAME_REQUEST_BASE_URL}#{id}"


				title = game["GameTitle"]
				release_date = game["ReleaseDate"]
				description = game["Overview"]
				esrb_rating = game["ESRB"]
				players = game["Players"]
				coop = game["Co-op"]
				platform = game["Platform"]
				publisher = game["Publisher"]
				developer = game["Developer"]



				boxart_url_end = game["Images"]["boxart"]
				image_url = "#{GAME_BASE_IMAGE_URL}#{boxart_url_end}"

				test = Game.where("title = ? AND platform = ?", title, platform).first
				if test != nil
					puts("Game already in")
					next
				end











				result = Nokogiri::XML(open(request_url))

				genres_noko = result.xpath("//genre")
				genres = []

				for i in 0..genres_noko.length - 1
					genres[i] = /.*<genre>(.*)<\/genre>.*/.match(genres_noko[i].to_s)[1]
				end

				metacritic_title = (title.downcase)
				metacritic_title.gsub!("---", '-')
				metacritic_title.gsub!(' - ', '---')
				metacritic_title.gsub!(': ', '-')
				metacritic_title.gsub!(' ', '-')
				metacritic_title.gsub!('_', '-')
				metacritic_title.gsub!("'", '')



				console_metacritic = CONSOLE_TO_METACRITIC_MAP[platform]
				metacritic_url = "#{METACRITIC_REQUEST_BASE_URL}#{console_metacritic}/#{metacritic_title}"


				if metacritic_url.include? "viva-pi"
					puts("fixing this shit")
					metacritic_url = "http://www.metacritic.com/game/xbox-360/viva-pinata-trouble-in-paradise"
				end


				if metacritic_url.include? "[platinum-hits]"
					puts("fixing this shit")
					next
				end

				if metacritic_url.include? "combo-pack"
					puts("fixing this shit")
					next
				end





			
				puts(metacritic_url)


				if (metacritic_url == "http://www.metacritic.com/game/pc/mission-against-terror")
					next
				end

				begin
					result = Nokogiri::HTML(open(metacritic_url))
					score = result.css("div.metascore_w.xlarge")[0]
					if score != nil
						score = score.css('span')
						score = /.*<span itemprop="ratingValue">(.*)<\/span>.*/.match(score.to_s)
						if score != nil
							score = score[1]
						else
							score = "0"
						end
					
					else
						score = "0"
					end
				rescue Exception => ex
					puts("score fubar'd")
					score = "0"
				end


				puts score

				search_title = StringHelper.create_search_title(title)


				g = Game.create!(title: title, release_date: release_date, 
					description: description, esrb_rating: esrb_rating, players: players,
					coop: coop, publisher: publisher, developer: developer, genres: genres, 
					metacritic_rating: score, image_url: image_url, search_title: search_title)

				puts(g.title)


			end
		end
	end
end



