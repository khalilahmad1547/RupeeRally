class CreateUserTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_transactions do |t|
      t.text :description, null: false, default: ''
      t.integer :transaction_type, null: false, default: 0
      t.integer :user_share, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
