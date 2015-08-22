class AddTagsToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :tags, :text
  end
end
