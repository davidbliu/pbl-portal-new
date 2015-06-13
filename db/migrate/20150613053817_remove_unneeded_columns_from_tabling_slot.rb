class RemoveUnneededColumnsFromTablingSlot < ActiveRecord::Migration
  def change
  	remove_column :tabling_slots, :start_time
  	remove_column :tabling_slots, :end_time
  end
end
