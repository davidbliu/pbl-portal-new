class AddTextToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :text, :text 
  	add_column :go_links, :parse_id, :string
  end
end
