class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.string :plan_id
      t.string :payment_method
      t.string :agreement_id
      t.string :client_id
      t.string :card_type
      t.integer :card_verification
      t.date :card_expires_on
      t.string :card_number

      t.timestamps
    end
  end
end
