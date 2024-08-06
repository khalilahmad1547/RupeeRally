class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false, default: ''

      t.timestamps
    end

    add_reference :groups, :created_by, foreign_key: { to_table: :users }, index: false
    add_index :groups, %i[name created_by_id], unique: true
  end
end
