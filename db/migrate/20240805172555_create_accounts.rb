class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, default: ''
      t.integer :balance_cents, null: false, default: 0
      t.integer :total_income_cents, null: false, default: 0
      t.integer :total_expense_cents, null: false, default: 0
      t.integer :initial_balance_cents, null: false, default: 0

      t.timestamps
    end

    add_reference :accounts, :user, foreign_key: true
    add_index :accounts, %i[user_id name], unique: true
  end
end
