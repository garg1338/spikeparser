require 'nokogiri'
require 'open-uri'
require 'timeout'
require 'restclient'


class StringHelper
    
  def self.sanitize_title(title)
      escape_for_space_characters = Regexp.escape('\\+-&|!(){}[]^~*?:&')
      escape_for_nothing_characters = Regexp.escape('\',®™.')
      str = title.gsub(/([#{escape_for_space_characters}])/, ' ')
      str = str.gsub(/([#{escape_for_nothing_characters}])/, '')
  end

  def self.create_search_title(title)
  	str = sanitize_title(title)

  	str = str.downcase

  	str = str.squish

  end


end




