class AddVndaCredentialsToShop < ActiveRecord::Migration
  def change
    add_column :shops, :api_key, :string
    add_column :shops, :api_password, :string
  end
end
