class AddGoogleEventFieldsToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :date, :time
  	add_column :events, :location, :string
  end
end
