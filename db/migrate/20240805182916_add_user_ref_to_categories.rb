class AddUserRefToCategories < ActiveRecord::Migration[7.1]
  def change
    add_reference :categories, :user, foreign_key: true
    add_index :categories, %i[user_id name], unique: true
  end
end
