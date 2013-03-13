class AddPhoneNumberToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :phone_number, :string
  end
end
