class CreateGroupAndMembers < ActiveRecord::Migration
  def change
    create_table :scavenger_groups do |t|
    	t.string :name
		  t.belongs_to :scavenger_theme
		  
	    t.timestamps
    end

    create_table :scavenger_group_members do |t|
    	t.belongs_to :scavenger_groups
    	t.belongs_to :member
    end
  end
end
