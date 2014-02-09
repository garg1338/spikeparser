class AddColumnToGames < ActiveRecord::Migration
  def change
    add_column :games, :column, :string
  end
end
