class CreatePlaylistVideos < ActiveRecord::Migration
  def change
    create_table :playlist_videos do |t|

      t.timestamps
    end
  end
end
