class AddEarnedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :earned_at, :datetime
  end
end
