class AddColumnSwipyDataToMembers < ActiveRecord::Migration
  def change
  	add_column :members, :swipy_data, :text
  end
end
