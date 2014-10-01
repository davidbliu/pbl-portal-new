class AdaptMemberModelForOld < ActiveRecord::Migration
  def change
  	add_column :members, :sex, :boolean
  	add_column :members, :email, :string
  	add_column :members, :phone, :string
  	add_column :members, :major, :string
  	add_column :members, :blurb, :text
  end
end
