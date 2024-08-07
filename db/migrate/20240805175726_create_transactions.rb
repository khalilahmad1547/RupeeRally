class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.text :description, null: false, default: ''
      t.integer :amount_cents, null: false, default: 0
      t.integer :divided_by, null: false, default: 0

      t.timestamps
    end

    add_reference :transactions, :user, foreign_key: true
  end
end
