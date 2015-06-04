class ChangeCommitments < ActiveRecord::Migration
  def change
  	add_column :members, :commitments, :text
  end
end

