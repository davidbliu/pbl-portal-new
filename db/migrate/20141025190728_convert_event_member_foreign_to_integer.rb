class ConvertEventMemberForeignToInteger < ActiveRecord::Migration
  def change
  	change_column :event_members, :member_id, :integer

  end
end
