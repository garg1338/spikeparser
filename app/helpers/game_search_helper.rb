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



  def self.resolve_messed_up_words(search_title_original, word1, word2)

    search_title = search_title_original
    if search_title.include? word1
      search_title = search_title.gsub(word1, word2)
      games_in_db = Game.where("search_title =?", search_title)

      if games_in_db.length != 0
        puts "Match found on mismatch!: " + search_title
        return games_in_db.first
      end
    end

    search_title = search_title_original
    if search_title.include? word2
      search_title = search_title.gsub(word2, word1)
      games_in_db = Game.where("search_title =?", search_title)

      if games_in_db.length != 0
        puts "Match found on mismatch!: " + search_title
        return games_in_db.first
      end
    end

    return nil

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


    #here we'll try words that may be messed up, NOTE FOR EACH WORD DIFFERENTIAL WE CHECK HERE, NEED TO ADD 
    #A SIMILAR CHECK TO are_games_same. IF TIME PERMITS, LOOK INTO REFACTORING THIS COUPLED CHANGE. 

    #super heroes as superheroes
    game = GameSearchHelper.resolve_messed_up_words(search_title_original, "super heroes", "superheroes")
    if game != nil 
      return game
    end

    #civilization and sid meier's civilization
    game = GameSearchHelper.resolve_messed_up_words(search_title_original, "civilization", "sid meiers civilization")
    if game != nil 
      return game
    end




    #try other words too
 
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



  def self.are_titles_same_but_diff_words(first_search_title, second_search_title, word1, word2)
    if first_search_title.include? word1 and second_search_title.include? word2
      return true
    end
    if first_search_title.include? word2 and second_search_title.include? word1
      return true
    end

  end


  #this method takes two search titles, and descriptions, and determines
  #if the titles are in reality for the exact same game, either due to the titles being
  #directly equal, or simply named differently, or if they have the exact same game description
  def self.are_games_same(first_search_title, second_search_title, first_game_descrip, second_game_descrip)

    if first_search_title == second_search_title
      return true
    end

    if first_search_title.include? "game of the year" and second_search_title.include? "game of the year"
      return true
    end


    #try game description
    if(first_game_descrip == second_game_descrip)
      return true
    end


    #here we try word differentials

      #superheroes
      if GameSearchHelper.are_titles_same_but_diff_words(first_search_title, second_search_title, "superheroes", "super heroes")
        return true
      end

      #civilization and sid meier's civilization
      if GameSearchHelper.are_titles_same_but_diff_words(first_search_title, second_search_title, "civilization", "sid meiers civilization")
        return true
      end


      #try others here


    return false
  end

end

