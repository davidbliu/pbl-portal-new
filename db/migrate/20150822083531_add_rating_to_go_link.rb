class AddRatingToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :rating, :integer
  	add_column :go_links, :votes, :integer
  end
end
