require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


module StringHelper
    
  def self.sanitize_title(title)
      escape_for_space_characters = Regexp.escape('\\+-&|!(){}[]^~*?:&')
      escape_for_nothing_characters = Regexp.escape('\',®™.’')
      str = title.gsub(/([#{escape_for_space_characters}])/, ' ')
      str = str.gsub(/([#{escape_for_nothing_characters}])/, '')
      str = str.gsub('dlc', '')

      str = str.gsub('amp;', 'and')
      str = str.gsub('&', 'and')
  end

  def self.create_search_title(title)

    str = title.downcase

  	str = sanitize_title(str)


  	str = str.squish

  end

  def self.prep_all_search_titles
    games_all = Game.all
    games_all.each do |game|
      str = StringHelper.create_search_title(game.title)
      game.update_attributes(:search_title => str)
      game.save!
    end
  end

end


