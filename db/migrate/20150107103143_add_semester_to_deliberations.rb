class AddSemesterToDeliberations < ActiveRecord::Migration
  def change
  	add_column :deliberations, :semester_id, :integer
  end
end
