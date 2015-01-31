class AddPaymentToApplicants < ActiveRecord::Migration
  def change
  	add_column :applicants, :payment_status, :integer
  	add_column :applicants, :payment_committee_id, :integer
  end
end
