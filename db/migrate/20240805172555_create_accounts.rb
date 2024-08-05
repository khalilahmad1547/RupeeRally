class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false, default: ''
      t.integer :balance_cents, null: false, default: 0
      t.integer :total_income, null: false, default: 0
      t.integer :total_expense, null: false, default: 0

      t.timestamps
    end
  end
end
