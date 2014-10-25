class ChangeEventMemberEventIdToInteger < ActiveRecord::Migration
  def change
  	# change_column :event_members, :event_id, :integer, 'integer USING CAST(event_id AS integer)'
  	execute 'ALTER TABLE event_members ALTER COLUMN event_id TYPE integer USING (event_id::integer)'
  end
end
