class AddNumClicksToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :num_clicks, :integer
  end
end
