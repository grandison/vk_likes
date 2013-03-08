class CreateLikeApps < ActiveRecord::Migration
  def change
    create_table :like_apps do |t|
      t.integer :likes_count
      t.string :name
      t.integer :account_id

      t.timestamps
    end
    add_index :like_apps, :account_id
  end
end
