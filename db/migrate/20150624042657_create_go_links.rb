class CreateGoLinks < ActiveRecord::Migration
  def change
    create_table :go_links do |t|
      t.string :key
      t.string :url
      t.text :description
      t.timestamps
    end
  end
end
