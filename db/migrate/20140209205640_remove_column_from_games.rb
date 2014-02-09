class RemoveColumnFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :column, :string
  end
end
