class CreateNewMemberData < ActiveRecord::Migration
  	def change
		create_table :new_member_data do |t|
		  t.integer :member_id
	      t.integer :committee
	      t.integer :commitee_member_type_id

	      t.timestamps
	    end
	end
end
