class AddUserRefToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :user, foreign_key: true
  end
end
