require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module SteamHelper
    


  def self.agePasser(product_url)
    shiny = RestClient.post(product_url, {'ageDay'=>'18', 'ageMonth'=>'February', 'ageYear'=>'1968'}){ 
      |response, request, result, &block|
      if [301, 302, 307].include? response.code
        response.follow_redirection(request, result, &block)
      else
        response.return!(request, result, &block)
      end
    }
    Nokogiri::HTML(shiny)
  end


  def self.getTitle(page)

    #game title
    game_title = page.at_xpath('//*[@id="main_content"]/div[1]/div[2]/div/div[3]').to_s
    game_title = /.*<div class="apphub_AppName">(.*)<\/div>.*/.match(game_title)

    if game_title == nil || game_title[0] == ""
      # puts "FUCKED WE ARE"
      return nil
    end

    game_title = game_title[1]
    return game_title
  end

  def self.getDescription(page)
    game_description = page.at_xpath('//*[@id="game_highlights"]/div[2]/div/div[2]').to_s
    game_description = game_description[38...game_description.length - 6]
    # if game_description.include? "Requires the base game"

    #   puts "dlc descrip!"
    #   description_area = page.css("div#game_area_description").to_s

    #   description_start = description_area.index("<h2>About the Game</h2>")


    #   description_area = description_area[description_start+23...description_area.length]

    #   puts description_area

    # end

    return game_description

  end

  def self.getGenres(page)
    page_string = page.to_s

    #obtain genres
      #genres = page.at_xpath('//*[@id="game_highlights"]/div[2]/div/div[4]/div[1]').to_s

    genre_start = page_string.index("Genre: ")
    genre_array = []
    if genre_start != nil
      genre_chunk = page_string[genre_start...page_string.length]
      genre_end = genre_chunk.index("<br>")

      genres = genre_chunk[0...genre_end]


      genres = genres.split(',')
      genres.each do |genre|
        start_index = genre.index('">')
        end_index = genre.index("</a>")

        if start_index != nil
          genre = genre[start_index+2...end_index] #obtain each genre
          genre_array.push(genre)
        end
      end
      return genre_array  
    end  

    return nil
  end


  def self.getDeveloper(page)
    page_string = page.to_s
    developer = "N/A"
    developer_start = page_string.index("<b>Developer:</b>")
    if !developer_start.nil?
      developer_chunk = page_string[developer_start...page_string.length]
      developer_end = developer_chunk.index("<br>")
      developer_chunk=developer_chunk[0...developer_end]
      start_index = developer_chunk.index('">')
      end_index = developer_chunk.index("</a>")
      developer = developer_chunk[start_index+2...end_index]
    end

    return developer
  end

  def self.getPublisher(page)
    page_string = page.to_s
    publisher = "N/A"
    publisher_start = page_string.index("<b>Publisher:</b>")
    if !publisher_start.nil?
      publisher_chunk = page_string[publisher_start...page_string.length]
      publisher_end = publisher_chunk.index("<br>")
      publisher_chunk=publisher_chunk[0...publisher_end]
      start_index = publisher_chunk.index('">')
      end_index = publisher_chunk.index("</a>")
      publisher = publisher_chunk[start_index+2...end_index]
    end

    return publisher    
  end

  def self.getReleaseDate(page)
    page_string = page.to_s
    release_date = "N/A"
    release_start = page_string.index("<b>Release Date:</b>")
    if !release_start.nil?
      release_chunk = page_string[release_start...page_string.length]
      release_end = release_chunk.index("<br>")
      release_chunk = release_chunk[0...release_end]

      release_date = release_chunk[21...release_end]

      release_date = release_date.strip
    end
    
    return release_date    
  end

  def self.getPricing(page)
    price_chunk = page.css(".game_purchase_action")[0]

    if price_chunk == nil
      price_chunk = page.css(".game_purchase_action")
    end

    original_price = price_chunk.css(".discount_original_price")[0].to_s
    sale_price = price_chunk.css(".discount_final_price")[0].to_s
    #this means the game isn't on sale
    if original_price == "" 
      original_price = price_chunk.css(".game_purchase_price.price")[0].to_s
      sale_price = ""

      if !original_price.include? "$" || original_price == ""
        original_price = ""
      end

    end
    #game is just on sale for regular price
    if original_price != "" && sale_price == ""
      original_price_start = original_price.index('">')
      original_price_end = original_price.index('</div>')
      original_price = original_price[original_price_start+2...original_price_end]
    end

    #game is on sale
    if original_price != "" && sale_price != ""
      original_price_start = original_price.index('">')
      original_price_end = original_price.index('</div>')
      original_price = original_price[original_price_start+2...original_price_end]

      sale_price_start = sale_price.index('">')
      sale_price_end = sale_price.index('</div>')
      sale_price = sale_price[sale_price_start+2...sale_price_end]
    end

    original_price = original_price.strip
    sale_price = sale_price.strip


    if sale_price == ""
      sale_price = original_price
    end



    arr = [original_price, sale_price]

    return arr

  end


  def self.getBoxArt(page)
    box_art_chunk = page.css(".game_header_image").to_s
    box_art_start = box_art_chunk.index('src="')
    box_art_end = box_art_chunk.index('">')
    box_art_url = box_art_chunk[box_art_start+5...box_art_end]
    return box_art_url
  end




  def self.extractPageInfo(page_link)
    page = SteamHelper.agePasser(page_link)
    puts page_link

    #game title
    game_title = SteamHelper.getTitle(page)

    if(game_title == nil)
      return
    end

    #game description
    game_description = SteamHelper.getDescription(page)

    #obtain genres
    genres = SteamHelper.getGenres(page)


    #developer
    developer = SteamHelper.getDeveloper(page)


    #publisher
    publisher = SteamHelper.getPublisher(page)

    #release date
    release_date = SteamHelper.getReleaseDate(page)


    #boxart
    box_art_url = SteamHelper.getBoxArt(page)

    #pricing
    price_arr = SteamHelper.getPricing(page)
    original_price = price_arr[0]
    sale_price = price_arr[1]


    if original_price == ""
      return
    end

    game = GameSearchHelper.find_right_game(game_title, game_description)
    search_title = StringHelper.create_search_title(game_title)

    puts game_title
    puts search_title


    if game == nil
      puts "Making new Game!"
      File.open("db/test_files/steam_misses.txt", 'a+') { |file| file << (search_title+"\n") }
      game = Game.create!(title: game_title, release_date: release_date, 
          description: game_description,  publisher: publisher, developer: developer, genres: genres, 
           image_url: box_art_url, search_title: search_title)

    elsif !(GameSearchHelper.are_games_same(game.search_title, search_title, game.description, game_description))
      puts "Making new game based on another game's info"

      puts game.search_title
      puts search_title

      File.open("db/test_files/steam_misses.txt", 'a+') { |file| file << (search_title+"\n") }

      if game.genres != nil
        genres = game.genres
      end

      game_new = Game.create!(title: game_title, release_date: release_date,
        description: game_description, publisher: publisher, developer: developer, genres: genres,
        image_url: box_art_url, search_title: search_title, metacritic_rating: game.metacritic_rating,
        coop: game.coop, esrb_rating: game.esrb_rating, players: game.players)

      game = game_new
    else
        #update fields?
      puts "no need to do anything but make the sale data"

    end

    #make the sale
    #make the sale history


    puts(game.title)
    puts(game.search_title)

    original_price = '%.2f' %  original_price.delete( "$" ).to_f
    sale_price = '%.2f' %  sale_price.delete( "$" ).to_f

    puts original_price
    puts sale_price

    game_sale = game.game_sales.create!(store: "Steam", url: page_link, origamt: original_price, saleamt: sale_price, occurrence: DateTime.now)
    game_sale_history = game.game_sale_histories.create!(store: "Steam", price: sale_price, occurred: DateTime.now)



    # if original_price == ""
    #   puts "Free to play!"
    # else
    #   puts original_price
    # end

    # if sale_price == ""
    #   puts "Not on sale!"
    # else
    #   puts sale_price
    # end


  end
end




