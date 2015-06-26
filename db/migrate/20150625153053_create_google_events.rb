class CreateGoogleEvents < ActiveRecord::Migration
  def change
    create_table :google_events do |t|
      t.string :name
      t.string :location
      t.text :description
      t.string :google_id
      t.time :time
      t.integer :semester_id
      t.timestamps
    end
  end
end
