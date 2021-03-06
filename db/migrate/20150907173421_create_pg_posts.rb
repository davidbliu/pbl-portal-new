class CreatePgPosts < ActiveRecord::Migration
  def change
    create_table :pg_posts do |t|
      t.string :title
      t.string :author
      t.string :view_permissions
      t.string :edit_permissions
      t.text :content
      t.text :tags
      t.string :post_type
      t.string :last_editor
      t.string :parse_id
      t.datetime :timestamp
      t.datetime :time_created
      t.timestamps
    end
  end
end
