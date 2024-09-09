class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, default: ''
      t.integer :amount_cents, null: false, default: 0
      t.integer :category_type, null: false, default: 0

      t.timestamps
    end

    add_reference :categories, :user, foreign_key: true
    add_index :categories, %i[user_id name category_type], unique: true
  end
end
