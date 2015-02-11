class MakeProfileLonger < ActiveRecord::Migration
  def change
  	change_column :members, :profile, :text
  end
end
