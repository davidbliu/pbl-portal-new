class TablingSlotMemberList < ActiveRecord::Migration
  def change
  	add_column :tabling_slots, :member_ids, :text
  	add_column :tabling_slots, :time, :integer
  end
end
