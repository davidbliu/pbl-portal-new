class AddMemberIdToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :member_id, :integer
  	add_column :go_links, :type, :string
  end
end
