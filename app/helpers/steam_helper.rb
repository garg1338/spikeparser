require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


class SteamHelper
    


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





  def self.extractPageInfo(page)

    #game title
    game_title = page.at_xpath('//*[@id="main_content"]/div[1]/div[2]/div/div[3]').to_s
    game_title = /.*<div class="apphub_AppName">(.*)<\/div>.*/.match(game_title)

    if game_title == nil || game_title[0] == ""
      puts "FUCKED WE ARE"
      return
    end

    game_title = game_title[1]


    #game description
    game_description = page.at_xpath('//*[@id="game_highlights"]/div[2]/div/div[2]').to_s
    game_description = game_description[38...game_description.length - 6]



    page_string = page.to_s


    #obtain genres
      #genres = page.at_xpath('//*[@id="game_highlights"]/div[2]/div/div[4]/div[1]').to_s

    genre_start = page_string.index("Genre: ")
    if genre_start != nil
      genre_chunk = page_string[genre_start...page_string.length]
      genre_end = genre_chunk.index("<br>")

      genres = genre_chunk[0...genre_end]


      genres = genres.split(',')
      genres.each do |genre|
        start_index = genre.index('">')
        end_index = genre.index("</a>")
        genre = genre[start_index+2...end_index] #obtain each genre
      end
    end


    #developer
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


    #publisher
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


    #release date
    release_date = "N/A"
    release_start = page_string.index("<b>Release Date:</b>")
    if !release_start.nil?
      release_chunk = page_string[release_start...page_string.length]
      release_end = release_chunk.index("<br>")
      release_chunk = release_chunk[0...release_end]

      release_date = release_chunk[21...release_end]

      release_date = release_date.strip
    end



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


    puts game_title
    if original_price == ""
      puts "Free to play!"
    else
      puts original_price
    end

    if sale_price == ""
      puts "Not on sale!"
    else
      puts sale_price
    end


  end
end




