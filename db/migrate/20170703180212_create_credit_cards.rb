class CreateCreditCards < ActiveRecord::Migration[5.1]
  def change
    create_table :credit_cards do |t|
      t.string :card_type
      t.integer :card_verification
      t.date :card_expires_on
      t.string :card_number

      t.timestamps
    end
  end
end
