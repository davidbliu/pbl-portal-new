class AddPermissionsToGoLink < ActiveRecord::Migration
  def change
  	add_column :go_links, :permissions, :string
  	add_column :go_links, :member_email, :string
  end
end
