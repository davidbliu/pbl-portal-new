class AddPointToScavengerPhoto < ActiveRecord::Migration
  def change
  	add_column :scavenger_photos, :points, :integer, :default=>0
  end
end
