class UpdatePlaylistData < ActiveRecord::Migration
  def change
  	# playlists should have a name and id
  	add_column :playlists, :name, :string

  	# playlistvideos should have playlist and video references
  	add_column :playlist_videos, :playlist_id, :integer
  	add_column :playlist_videos, :video_id, :integer
  end
end
