class CreateVideoTags < ActiveRecord::Migration
  def change
    create_table :video_tags do |t|
      t.belongs_to :video
      t.belongs_to :tag
      t.timestamps
    end
  end
end
