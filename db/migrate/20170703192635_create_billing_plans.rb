class CreateBillingPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_plans do |t|
      t.string :name
      t.string :description
      t.float :amount
      t.string :currency
      t.boolean :trial
      t.string :trial_period
      t.string :plan_id
      t.integer :client_id
      t.timestamps
    end
  end
end
