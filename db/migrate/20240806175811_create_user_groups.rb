class CreateUserGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :user_groups do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
