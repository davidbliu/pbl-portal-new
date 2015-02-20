class CreateScavengerPhotos < ActiveRecord::Migration
  def change
    create_table :scavenger_photos do |t|

      t.text :image
      t.text :description
	  t.belongs_to :member
	  t.belongs_to :scavenger_theme
	  
      t.timestamps
    end
  end
end
