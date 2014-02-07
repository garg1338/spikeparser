require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


class AmazonHelper
  def self.parseProductsOffResultPage(result)
    rows = result.css(".result.product")
    rows.each do |row|

      title = row.css(".productTitle")

      title = title.to_s



      if (!title.include? "[")
        next
      end

      if(title.include? "MAC")
        next
      end

      title_start = title.index('<br clear="all">')
      title_end = title.index("[")

      title = title[title_start+16...title_end]



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
    end
  end

  def self.extractPageInfo(product_url)

    result = RestClient.get(product_url)
    result = Nokogiri::HTML(result)



    # File.open("db/test_files/" + product_url +".html", 'w') { |file| file.write(result.to_s) }


    parseProductsOffResultPage(result)




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