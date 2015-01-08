class ChangeApplicantImageToText < ActiveRecord::Migration
  def change
  	change_column :applicants, :image, :text
  end
end
