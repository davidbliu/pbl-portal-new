class CreateScavengerThemes < ActiveRecord::Migration
  def change
    create_table :scavenger_themes do |t|
      t.string :name
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
