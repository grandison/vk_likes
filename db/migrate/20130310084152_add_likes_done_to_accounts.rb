class AddLikesDoneToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :likes_done, :integer, :default => 0
  end
end
