class ChangeGoLinkToText < ActiveRecord::Migration
  def change
  	change_column :go_links, :key, :text
  	change_column :go_links, :url, :text
  	change_column :go_links, :description, :text
  end
end
