class AddRefsToUserTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_transactions, :user, foreign_key: true
    add_reference :user_transactions, :account, foreign_key: true, null: true
    add_reference :user_transactions, :category, foreign_key: true, null: true
    add_reference :user_transactions, :transaction, foreign_key: true
    add_reference :user_transactions, :paid_by, foreign_key: { to_table: :users }

    remove_index :user_transactions, :account_id, name: 'index_user_transactions_on_account_id'
    add_index :user_transactions, :account_id, where: 'account_id IS NOT NULL'
    remove_index :user_transactions, :category_id, name: 'index_user_transactions_on_category_id'
    add_index :user_transactions, :category_id, where: 'category_id IS NOT NULL'
  end
end
