class AddPriorityToPlatlists < ActiveRecord::Migration
  def change
  	add_column :playlists, :priority, :integer
  end
end
