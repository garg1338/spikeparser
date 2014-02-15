require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module AmazonHelper


  #we need a separate function to get the first page of amazon because it is different from the other pages
  def self.parse_first_sale_page
    amzn_first_page_url = "http://www.amazon.com/s?ie=UTF8&page=1&rh=n%3A2445220011"


    result = RestClient.get(amzn_first_page_url)
    result = Nokogiri::HTML(result)


    rows = result.css(".result.product")


    rows.each do |row|


      title_chunk = row.css("a.title").to_s
      title_start = title_chunk.index('">')
      title_end = title_chunk.index("[")

      title = title_chunk[title_start+2...title_end]

      search_title = StringHelper.create_search_title(title)

      game = GameSearchHelper.find_right_game(search_title, "no similar description")

      if game == nil
        puts "NO GAME FOUND"
        next
      end


      amzn_price_chunk = row.css(".toeOurPrice").to_s
      price_chunk_start = amzn_price_chunk.index('">$')
      price_chunk_end = amzn_price_chunk.index('</a>')

      sale_price = amzn_price_chunk[price_chunk_start+2...price_chunk_end]
      puts sale_price

      original_price = sale_price

      original_price_chunk = row.css("strike").to_s

      if original_price_chunk != ""
        original_price_start = original_price_chunk.index('<strike>')
        original_price_end = original_price_chunk.index('</strike>')
        original_price = original_price_chunk[original_price_start+8...original_price_end]
      end

      puts original_price

      product_url = row.css(".title").css("a")[0].to_s

      link_start = product_url.index('<a class="title" href="')
      link_end = product_url.index('">')

      product_url = product_url[link_start+23...link_end]

      puts product_url



      original_price = '%.2f' %  original_price.delete( "$" ).to_f
      sale_price = '%.2f' %  sale_price.delete( "$" ).to_f
      game_sale = game.game_sales.create!(store: "Amazon", url: product_url, origamt: original_price, saleamt: sale_price, occurrence: DateTime.now)
      game_sale_history = game.game_sale_histories.create!(store: "Amazon", price: sale_price, occurred: DateTime.now)




    end


  end



  def self.parse_products_off_result_page(result)
    rows = result.css(".result.product")
    rows.each do |row|

      title = row.css(".productTitle")

      title = title.to_s


      title_encode = title.encode("UTF-8", invalid: :replace, undef: :replace)


      if !(title_encode.valid_encoding?)
        next
      end


      if (!title.include? "[")
        next
      end

      if(title.include? "MAC")
        next
      end

      title_start = title.index('<br clear="all">')
      title_end = title.index("[")

      title = title[title_start+16...title_end]


      #seeing if we find a match
      search_title = StringHelper.create_search_title(title)

      game = GameSearchHelper.find_right_game(search_title, "no similar description")

      if game == nil
        puts "NO GAME FOUND"
        next
      end




      if row.to_s.include? "Sign up to be notified when this item becomes available."
        next
      end

      if row.to_s.include? "Currently unavailable"
        next
      end

      price_chunk = row.css(".newPrice").to_s



      sale_price_start = price_chunk.index("<span>")

      sale_price_end = price_chunk.index("</span>")

      sale_price = price_chunk[sale_price_start+6...sale_price_end]

      original_price = sale_price

      if price_chunk.include? "<strike>"
        original_price_start = price_chunk.index("<strike>")
        original_price_end = price_chunk.index("</strike>")
        original_price = price_chunk[original_price_start+8...original_price_end]
      end

      puts title
      puts original_price
      puts sale_price
      puts "game found!"
      original_price = '%.2f' %  original_price.delete( "$" ).to_f
      sale_price = '%.2f' %  sale_price.delete( "$" ).to_f


      product_url = row.css(".productTitle").css("a")[0].to_s

      link_start = product_url.index('<a href="')
      link_end = product_url.index('">')

      product_url = product_url[link_start+9...link_end]

      game_sale = game.game_sales.create!(store: "Amazon", url: product_url, origamt: original_price, saleamt: sale_price, occurrence: DateTime.now)
      game_sale_history = game.game_sale_histories.create!(store: "Amazon", price: sale_price, occurred: DateTime.now)

    end
  end

  def self.extract_page_info(product_url)

    result = RestClient.get(product_url)
    result = Nokogiri::HTML(result)



    # File.open("db/test_files/" + product_url +".html", 'w') { |file| file.write(result.to_s) }


    parse_products_off_result_page(result)




    next_url_chunk = result.css(".pagnNext").to_s
    next_url_start = next_url_chunk.index('<a href="')
    next_url_end = next_url_chunk.index('" class')
    next_url = next_url_chunk[next_url_start+9...next_url_end]

    next_url_chunks = next_url.split("&amp;")

    next_url = "";

    next_url_chunks.each do |url_chunk|
      next_url = next_url + "&" + url_chunk
    end

    next_url = next_url[1...next_url.length]

    puts next_url
    puts "\n"
  end
end