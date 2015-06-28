class AddPointsToGoogleEvents < ActiveRecord::Migration
  def change
  	add_column :google_events, :points, :integer
  end
end
