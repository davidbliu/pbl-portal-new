class AddPointsToThemes < ActiveRecord::Migration
  def change
  	add_column :scavenger_themes, :points, :integer
  	add_column :scavenger_themes, :late_points, :integer
  	add_column :scavenger_themes, :winning_photo, :integer
  end
end
