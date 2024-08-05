class AddUserRefToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_reference :accounts, :user, foreign_key: true
    add_index :accounts, %i[user_id name], unique: true
  end
end
