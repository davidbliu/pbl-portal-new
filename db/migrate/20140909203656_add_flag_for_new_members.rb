class AddFlagForNewMembers < ActiveRecord::Migration
  def change
  	add_column :members, :confirmation_status, :integer
  end

  # def up
  # 	add_column :members, :confirmation_status, :integer
  # end

end
