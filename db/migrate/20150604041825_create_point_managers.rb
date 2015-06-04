class CreatePointManagers < ActiveRecord::Migration
  def change
    create_table :point_managers do |t|
    	t.integer :semester_id
        t.timestamps
    end
  end
end
