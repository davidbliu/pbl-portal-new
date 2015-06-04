class AddPointsToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :points, :integer
  end
end
