class AddPositionToCommitteeMember < ActiveRecord::Migration
  def change
  	add_column :committee_members, :position_id, :integer
  end
end
