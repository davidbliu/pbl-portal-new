class ChangeEventPointsToInteger < ActiveRecord::Migration
  def change
  	execute 'ALTER TABLE event_points ALTER COLUMN event_id TYPE integer USING (event_id::integer)'
  end
end
