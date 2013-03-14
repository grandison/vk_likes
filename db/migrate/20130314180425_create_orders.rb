class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :likes_count
      t.string :vk_url

      t.timestamps
    end
  end
end
