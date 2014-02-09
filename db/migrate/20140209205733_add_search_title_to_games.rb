class AddSearchTitleToGames < ActiveRecord::Migration
  def change
    add_column :games, :search_title, :string
  end
end
