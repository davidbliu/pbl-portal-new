class AddPositionToCommitteeMember < ActiveRecord::Migration
  def change
  	add_column :committee_members, :position, :integer
  end
end
