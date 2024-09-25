class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.text :description, null: false, default: ''
      t.integer :amount_cents, null: false, default: 0
      t.integer :divided_by, null: false, default: 0
      t.string :selected_date, null: false, default: ''
      t.string :selected_time, null: false, default: ''
      t.integer :transaction_type, null: false, default: 0
      t.integer :direction, null: false, default: 0
      t.integer :user_share, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :parent_transaction_id, null: true

      t.timestamps
    end

    add_reference :transactions, :user, foreign_key: true
    add_reference :transactions, :account, foreign_key: true, null: true, index: false
    add_reference :transactions, :category, foreign_key: true, null: true, index: false
    add_reference :transactions, :paid_by, foreign_key: { to_table: :users }

    add_index :transactions, :account_id, where: 'account_id IS NOT NULL'
    add_index :transactions, :category_id, where: 'category_id IS NOT NULL'
    add_index :transactions, :parent_transaction_id, where: 'parent_transaction_id IS NOT NULL'
  end
end
