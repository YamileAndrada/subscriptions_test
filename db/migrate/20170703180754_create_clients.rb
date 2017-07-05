class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.text :street
      t.string :city
      t.string :state
      t.string :email
      t.integer :postal_code
      t.string :country_code
      t.string :credit_card_id

      t.timestamps
    end
  end
end
