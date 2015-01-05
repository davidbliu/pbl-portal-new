class AddRegistrationCommentColumnToMember < ActiveRecord::Migration
  def change
  	add_column :members, :registration_comment, :text
  end
end
