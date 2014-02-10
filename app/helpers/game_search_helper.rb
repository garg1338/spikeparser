require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module GameSearchHelper
    
  def self.find_right_game(title, description)


    search_title = StringHelper.create_search_title(title)
    games_in_db = Game.where("search_title =?", search_title)

    if games_in_db.length == 0
      puts "Game Not found! Trying to resolve now!"
      games_in_db = Game.where("description =?", description)

      if games_in_db.length != 0
        return games_in_db.first
      end

      GameSearchHelper.resolve_name_miss_of_vendor_title(search_title)


    else
      puts "Match Found!: " + search_title
      return games_in_db.first
    end
  end




  #this method takes the vendor title and sees if it can tweak the vendor title to
  #find a match in the game database
  def self.resolve_name_miss_of_vendor_title(search_title_original)


    #try adding the word edition, sometimes it gets missed
    search_title = search_title_original + " edition"
    games_in_db = Game.where("search_title =?", search_title)

    if games_in_db.length != 0
      puts "Match found on mismatch!: " + search_title
      return games_in_db.first
    end


    #now we try chopping off the word edition, etc.

    search_title = search_title_original

    if(search_title.include? "edition" or search_title.include? "game of the year" or  search_title.include? "gold" or search_title.include? "package" or search_title.include? "deluxe" or search_title.include? "collection")

      until search_title.length == 0
        search_title = search_title.split(' ')[0...-1].join(' ')

        games_in_db = Game.where("search_title =?", search_title)

        if games_in_db.length != 0
          puts "Match found on mismatch!: " + search_title
          return games_in_db.first
        end

      end
    end

    puts "nothing found sorry!"
  end



  def self.are_titles_same(first_search_title, second_search_title)

    if first_search_title == second_search_title
      return true
    end

    if first_search_title.include? "game of the year" and second_search_title.include? "game of the year"
      return true
    end

    return false


  end

end

