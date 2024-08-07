class AddRefsToUserTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_transactions, :user, foreign_key: true, index: false
    add_reference :user_transactions, :account, foreign_key: true, null: true, index: false
    add_reference :user_transactions, :category, foreign_key: true, null: true, index: false
    add_reference :user_transactions, :transaction, foreign_key: true, index: false
    add_reference :user_transactions, :paid_by, foreign_key: { to_table: :users }, index: false

    add_index :user_transactions, :account_id, where: 'account_id IS NOT NULL'
    add_index :user_transactions, :category_id, where: 'category_id IS NOT NULL'
  end
end
