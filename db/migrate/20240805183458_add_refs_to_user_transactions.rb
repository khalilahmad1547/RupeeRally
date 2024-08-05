class AddRefsToUserTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_transactions, :user, foreign_key: true
    add_reference :user_transactions, :account, foreign_key: true
    add_reference :user_transactions, :category, foreign_key: true
    add_reference :user_transactions, :transaction, foreign_key: true
  end
end
