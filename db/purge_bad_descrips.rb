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

# Game.delete_all


games_all = Game.all

games_all.each do |game|
	description = game.description

	if description != nil and description.include? "Requires the base game"
		Game.destroy(game.id)
	end
end








# the elder scrolls v skyrim dlc hearthfire
