class CreateGoLinkClicks < ActiveRecord::Migration
  def change
    create_table :go_link_clicks do |t|
      t.integer :member_id
      t.integer :go_link_id
      t.string :go_link_key
      t.timestamps
    end
  end
end
