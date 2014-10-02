class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :youtube_id
      t.string :title
      t.datetime :uploaded_at
      t.timestamps
    end
  end
end
