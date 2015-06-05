class CreateTablingManagers < ActiveRecord::Migration
  def change
    create_table :tabling_managers do |t|

      t.timestamps
    end
  end
end
