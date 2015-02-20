class AddCorrectToPhoto < ActiveRecord::Migration
  def change
  	add_column :scavenger_photos, :group_id, :integer
  	add_column :scavenger_photos, :confirmation_status, :integer
  end
end
